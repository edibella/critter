classdef FindParams < handle
  properties
    Data
    bestImage
    totalIterations
  end
  methods
    function self = FindParams(Data, bestImage)
      % Stash variables
      self.Data = Data;
      self.bestImage = bestImage;
    end

    function plot_stcr_rmse(self, spatialParams, temporalParams, totalIterations)
      % set iterations and find lengths
      self.totalIterations = totalIterations;
      nSpatialParams = length(spatialParams);
      nTemporalParams = length(temporalParams);

      % Init loop variables
      [spatialParams, temporalParams] = meshgrid(spatialParams, temporalParams);
      nTotalParams = nSpatialParams * nTemporalParams;
      resultsMatrix = zeros(size(spatialParams));

      for iParam = 1:nTotalParams
        temporal = temporalParams(iParam);
        spatial = spatialParams(iParam);
        display(['spatial: ' num2str(spatial) ' | temporal: ' num2str(temporal)])
        % Fidelity is always 1
        weights = [spatial, temporal];
        rmse = self.stcr_param_rmse(weights);
        display(['rmse: ' num2str(rmse)])
        resultsMatrix(iParam) = rmse;
      end

      % Plot
      surf(spatialParams, temporalParams, resultsMatrix)
      xlabel('spatial')
      ylabel('temporal')
    end

    function spatialParam = find_best_scr(self, initialGuess, totalIterations, Opts)
      % Handle missing Opts
      if nargin == 3
        Opts = struct
      end

      % fire up fminsearch
      self.totalIterations = totalIterations;
      functionHandle = @(weight) self.scr_param_rmse(weight);
      spatialParam = fminsearch(functionHandle, initialGuess, Opts);
    end

    function Weights = find_best_stcr(self, Weights, totalIterations, Opts)
      % Handle missing Opts
      if nargin == 3
        Opts = struct
      end
      self.totalIterations = totalIterations;
      % fminsearch works with variable vectors, not structs
      initialGuessArray = [Weights.spatial, Weights.temporal];
      functionHandle = @(weights) self.stcr_param_rmse(weights);
      weights = fminsearch(functionHandle, initialGuessArray, Opts);

      % put them back into a struct
      Weights.spatial = weights(1);
      Weights.temporal = weights(2);
    end

    function difference = scr_param_rmse(self, weight)
      % Create Opts Struct
      Opts.Weights.fidelity = 1;
      Opts.Weights.spatial = weight;
      Opts.nIterations = self.totalIterations;

      % Reconstruct with parameter and number of iterations
      imageVolume = Critter.use_scr(self.Data, Opts);
      finalImage = Critter.sum_of_squares(imageVolume);
      
      % Get RMSE difference between final best.
      difference = self.rmse(imageVolume);
    end

    function difference = stcr_param_rmse(self, weights)
      % Create Opts Struct
      Opts.Weights.fidelity = 1;
      Opts.Weights.spatial = weights(1);
      Opts.Weights.temporal = weights(2);
      Opts.nIterations = self.totalIterations;

      % Reconstruct with parameter and number of iterations
      imageVolume = Critter.use_stcr(self.Data, Opts);
      finalImage = Critter.sum_of_squares(imageVolume);

      % Get RMSE difference between final best.
      difference = self.rmse(imageVolume);
    end

    function result = rmse(self, imageVolume)
      difference = self.bestImage(:) - imageVolume(:);
      squaredDifference = abs(difference.^2);
      result = sqrt(mean(squaredDifference));
    end
  end
end
