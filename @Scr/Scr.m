classdef Scr < Critter.BaseReconstructor
  properties
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
      self@Critter.BaseReconstructor(kSpaceInput, fftObj, Opts)
    end

    function pre_allocate_loop_variables(self)
      self.maskedImageEstimate = self.imageEstimate;
      if(self.debug)
        self.fidelityNorm = zeros(1, self.nIterations);
        self.spatialNorm = zeros(1, self.nIterations);
      end
    end

    function apply_constraints(self, iIteration)
      self.update_fidelity_term();
      self.update_spatial_term();
      self.update_image_estimate();
      self.update_masked_image_estimate(iIteration);
    end

    function debug_in_loop(self, iIteration)
      self.update_debug_vals();
      self.plot_norms(iIteration);
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
      imageUpdate = self.stepSize * self.fidelityUpdateTerm;
      if ~isempty(self.spatialUpdateTerm)
        imageUpdate = imageUpdate + self.stepSize * self.spatialUpdateTerm;
      end
      self.imageEstimate = self.imageEstimate + imageUpdate;
    end

    function update_masked_image_estimate(self, iIteration)
      kSpaceEstimate = self.fftObject * self.imageEstimate;
      self.maskedImageEstimate = self.fftObject' * kSpaceEstimate;
    end

    % Debug functions
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
