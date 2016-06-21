classdef Stcr < Critter.Scr
  properties
    temporalUpdateTerm = 0
    temporalNorm
    temporalArray
  end
  methods
    function self = Stcr(kSpaceInput, fftObj, Opts)
      self@Critter.Scr(kSpaceInput, fftObj, Opts)
    end

    function pre_allocate_loop_variables(self)
      % Call super
      pre_allocate_loop_variables@Critter.Scr(self);
      % Add to it the temporal term
      self.temporalUpdateTerm = zeros(size(self.imageEstimate), 'single');
      % and the debug term if needed
      if self.debug
        self.temporalNorm = zeros(1, self.nIterations);
      end
    end

    function imageEstimate = apply_constraints(self, iIteration)
      self.update_fidelity_term();
      self.update_spatial_term();
      self.update_temporal_term();
      self.update_image_estimate();
      self.update_masked_image_estimate(iIteration);
    end

    function update_image_estimate(self)
      % Call super
      update_image_estimate@Critter.Scr(self);
      % Add temporal term
      if ~isempty(self.temporalUpdateTerm)
        imageUpdate = self.stepSize * self.temporalUpdateTerm;
        self.imageEstimate = self.imageEstimate + imageUpdate;
      end
    end

    function update_temporal_term(self)
      % Take two differences in time dimension
      firstDiff = diff(self.imageEstimate, 1, 3);
      normalizationFactorSquared =  self.BETA_SQUARED + abs(firstDiff).^2;
      firstDiffNorm = firstDiff ./ sqrt(normalizationFactorSquared);
      secondDiff = diff(firstDiffNorm, 1, 3);

      % Fill term with pieces of differences
      self.temporalUpdateTerm(:,:,1) = firstDiffNorm(:,:,1);
      self.temporalUpdateTerm(:,:,2:end-1) = secondDiff;
      self.temporalUpdateTerm(:,:,end) = -firstDiffNorm(:,:,end);

      % Save as weighted temporal update term
      self.temporalUpdateTerm = self.Weights.temporal * self.temporalUpdateTerm;
    end

    function update_debug_vals(self, iIteration)
      update_debug_vals@Critter.Scr(self, iIteration);
      temporalDiff = abs(diff(self.imageEstimate,1,3));
      self.temporalNorm(iIteration) = sum(temporalDiff(:));
      % Prep data for plotting
      self.temporalArray = self.Weights.temporal * self.temporalNorm(1:iIteration);
      self.totalNorm = self.totalNorm + self.temporalArray;
    end

    function plot_norms(self, iIteration)
      % Plots
      figure(100);clf; hold on;
      subplot(2,2,1); plot(self.fidelityArray,'c*-'); title('Fidelity norm')
      subplot(2,2,2); plot(self.spatialArray,'bx-'); title('Spatial norm')
      subplot(2,2,3); plot(self.temporalArray,'kx-');  title('Temporal norm')
      subplot(2,2,4); plot(self.totalNorm, 'bx-'); title('Total Cost')
    end

  end
end
