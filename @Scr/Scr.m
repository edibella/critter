classdef Scr < Critter.BaseReconstructor
  % NOTE: Some of the naming here was tricky to figure out, so I probably
  % haven't selected the best names. In particular, for the multi-coil stuff
  % I often have two copies of important variables lying around a "3D" version
  % and a "4D" version. Spatial (and temporal) TV is applied to a combined-coil
  % "3D" imageEstimate, but for fidelity operations, I need the original "4D" version
  % so that one (and its relatives) is marked by the suffix "RepTime" since it is just
  % the image Estimate repeated in a time dimension to make it 4 dimensional hence
  % imageEstimateRepTime
  properties (Constant)
    MULTI_COIL = false;
  end
  properties
    maskedImageEstimate
    fidelityUpdateTerm
    spatialUpdateTerm
    fidelityNorm
    fidelityArray
    spatialNorm
    spatialArray
    totalNorm

    nCoil
    multiCoil
    senseMaps
    imageEstimateRepTime
    senseImageRepTime
    senseMapsRepTime
    conjSenseMapRepTime
    invSenseMagImageRepTime
  end
  methods
    function self = Scr(kSpaceInput, fftObj, Opts)
      self@Critter.BaseReconstructor(kSpaceInput, fftObj, Opts)
      % check multi-coil
      if isfield(Opts, 'multiCoil')
        self.multiCoil = Opts.multiCoil;
      else
        self.multiCoil = self.MULTI_COIL;
      end

      if Opts.multiCoil
        self.senseMaps = Opts.senseMaps;
      end
    end

    % Superclass method overwrites
    function prep_for_loop(self)
      % pre-allocate variables
      self.maskedImageEstimate = self.imageEstimate;

      if self.debug
        self.fidelityNorm = zeros(1, self.nIterations);
        self.spatialNorm = zeros(1, self.nIterations);
      end

      % prepare for multi coil stuff
      if self.multiCoil
        self.prep_multi_coil_vars();
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

    % Methods for this class
    function update_fidelity_term(self)
      fidelityTerm = self.imageInput - self.maskedImageEstimate;
      self.fidelityUpdateTerm = self.Weights.fidelity * fidelityTerm;
      % multi coil fidelity gives a 4d result above, so now we compress it to 3D
      if self.multiCoil
        senseFidelityUpdate = self.fidelityUpdateTerm .* self.conjSenseMapRepTime;
        fidelitySumOfCoils = sum(senseFidelityUpdate, 4);
        self.fidelityUpdateTerm = self.invSenseMagImageRepTime .* fidelitySumOfCoils;
      end
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
      if self.multiCoil
        self.imageEstimateRepTime = repmat(self.imageEstimate, [1 1 1 self.nCoil]);
        self.senseImageRepTime = self.senseMapsRepTime .* self.imageEstimateRepTime;
        kSpaceEstimate = self.fftObject * self.senseImageRepTime;
      else
        kSpaceEstimate = self.fftObject * self.imageEstimate;
      end
      self.maskedImageEstimate = self.fftObject' * kSpaceEstimate;
    end

    % Multi coil functions
    function prep_multi_coil_vars(self)
      [nRow, nCol, nTime, self.nCoil] = size(self.imageEstimate);
      self.senseMaps = self.scaleFactor * self.senseMaps;
      conjSenseMaps = conj(self.senseMaps);
      self.senseMapsRepTime = repmat(self.senseMaps,[1 1 1 nTime]);
      self.senseMapsRepTime = permute(self.senseMapsRepTime, [1 2 4 3]);
      self.conjSenseMapRepTime = single(conj(self.senseMapsRepTime));
      invSenseMagImage = 1./sum(abs(self.senseMaps).^2,3);
      self.invSenseMagImageRepTime = repmat(invSenseMagImage, [1 1 nTime]);

      self.imageEstimate = single(zeros(nRow,nCol,nTime));

      for i = 1:nTime
        combinedImageCoils = single(zeros(nRow,nCol));
        for j = 1:self.nCoil
          conjSenseMapCoil = conjSenseMaps(:,:,j);
          singleImageCoil = self.imageInput(:,:,i,j);
          combinedImageCoils = combinedImageCoils + singleImageCoil .* conjSenseMapCoil;
        end
        self.imageEstimate(:,:,i) = invSenseMagImage .* combinedImageCoils;
      end

      self.imageEstimateRepTime = repmat(self.imageEstimate, [1 1 1 self.nCoil]);

      % create self.maskedImageEstimate
      self.senseImageRepTime = self.senseMapsRepTime .* self.imageEstimateRepTime;
      senseKSpaceRepTime = self.fftObject * self.senseImageRepTime;
      self.maskedImageEstimate = self.fftObject' * senseKSpaceRepTime;
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
