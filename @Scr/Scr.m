classdef Scr < handle
  properties (Constant)
    BETA_SQUARED = 1e-8;
    STEP_SIZE = 0.5;
    N_ITERATIONS = 70;
    MAGIC_SCALE_NUMBER = 4;
  end
  properties
    kSpaceInput
    fftObject
    Weights
    imageInput
    nIterations
    debug
    isStcr

    scaleFactor
    imageEstimate
    maskedImageEstimate
    fidelityUpdateTerm
    spatialUpdateTerm
    fidelityNorm
    fidelityArray
    spatialNorm
    spatialArray
    totalNorm
  end
  methods
    function self = Scr(kSpaceInput, fftObj, Opts)
      self.kSpaceInput = single(kSpaceInput);
      self.fftObject = fftObj;
      self.Weights = Opts.Weights;
      self.isStcr = isa(self, 'Critter.Stcr');

      % TODO: Make this dynamic given defaults from constants
      if isfield(Opts, 'nIterations')
        self.nIterations = Opts.nIterations;
      else
        self.nIterations = self.N_ITERATIONS;
      end

      if isfield(Opts, 'debug')
        self.debug = Opts.debug;
      else
        self.debug = false;
      end
    end

    function finalImage = reconstruct(self)
      self.create_image_input();
      self.scale_image_input();
      self.iteratively_reconstruct();
      finalImage = self.unscale_image();
    end

    function create_image_input(self)
      self.imageInput = self.fftObject' * self.kSpaceInput;
    end

    function scale_image_input(self)
      maxIntensity = max(abs(self.imageInput(:)));
      self.scaleFactor = self.MAGIC_SCALE_NUMBER / maxIntensity;
      self.imageInput = single(self.imageInput * self.scaleFactor);
    end

    function imageEstimate = iteratively_reconstruct(self)
      self.pre_allocate_loop_variables();
      for iIteration = 1:self.nIterations
        self.update_fidelity_term();
        self.update_spatial_term();
        if self.isStcr
          self.update_temporal_term();
        end
        self.update_image_estimate();
        self.update_masked_image_estimate();
        if self.debug
          self.update_debug_vals(iIteration);
          self.plot_norms(iIteration);
        end
      end
    end

    function pre_allocate_loop_variables(self)
      self.imageEstimate = self.imageInput;
      self.maskedImageEstimate = self.imageEstimate;
      if(self.debug)
        self.fidelityNorm = zeros(1, self.nIterations);
        self.spatialNorm = zeros(1, self.nIterations);
      end
    end

    function update_fidelity_term(self)
      fidelityTerm = self.imageInput - self.maskedImageEstimate;
      self.fidelityUpdateTerm = self.Weights.fidelity * fidelityTerm;
    end

    function update_spatial_term(self)
      spatialTerm = TV_Spatial_2D(self.imageEstimate, self.BETA_SQUARED);
      self.spatialUpdateTerm = self.Weights.spatial * spatialTerm;
    end

    function update_image_estimate(self)
      imageUpdate = self.STEP_SIZE * ...
                        (self.fidelityUpdateTerm + self.spatialUpdateTerm);
      self.imageEstimate = self.imageEstimate + imageUpdate;
    end

    function update_masked_image_estimate(self)
      kSpaceEstimate = self.fftObject * self.imageEstimate;
      self.maskedImageEstimate = self.fftObject' * kSpaceEstimate;
    end

    function finalImage = unscale_image(self)
      finalImage = self.imageEstimate ./ self.scaleFactor;
    end

    function update_debug_vals(self, iIteration)
      self.fidelityNorm(iIteration) = sum(abs(self.fidelityUpdateTerm(:)).^2);
      self.spatialNorm(iIteration) = self.compute_spatial_norm();

      % Prep data for plot, have to keep only part of array with data, and need to share this with subclass, so it's separate from plot command
      self.fidelityArray = self.Weights.fidelity * self.fidelityNorm(1:iIteration);
      self.spatialArray = self.Weights.spatial * self.spatialNorm(1:iIteration);
      self.totalNorm = self.fidelityArray + self.spatialArray;
    end

    function spatialNorm = compute_spatial_norm(self)
      % Spatial Norm
      % - get abs diff in each direction
      yDiff = diff(self.imageEstimate, 1, 1);
      xDiff = diff(self.imageEstimate, 1, 2);
      xNorm = abs(xDiff);
      yNorm = abs(yDiff);
      %  - Truncate
      oneLess = size(self.imageEstimate, 1) - 1;
      yNorm = yNorm(1:oneLess,1:oneLess,:);
      xNorm = xNorm(1:oneLess,1:oneLess,:);
      % - compute norm
      spatialNorm = sum(sqrt(abs(xNorm(:)).^2 + abs(yNorm(:)).^2));
    end

    function plot_norms(self, iIteration)
      % Plots
      figure(100);clf; hold on;
      subplot(1,3,1); plot(self.fidelityArray,'c*-'); title('Fidelity norm')
      subplot(1,3,2); plot(self.spatialArray,'bx-'); title('Spatial norm')
      subplot(1,3,3); plot(self.totalNorm, 'bx-'); title('Total Cost')
    end
  end
end
