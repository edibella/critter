% Method for trying your own weights and seeing a plot / results in order to find the min on your own - sort of alpha testing this, seems useful, needs to be cleaned up a bit. Will document properly when it's out of alpha.
function [resultsMatrix, spatialParams, temporalParams] = plot_stcr_rmse(self, spatialParams, temporalParams, totalIterations)

  % set iterations and find lengths
  self.totalIterations = totalIterations;
  nSpatialParams = length(spatialParams);
  nTemporalParams = length(temporalParams);

  % Take a list of spatial and temporal params, find rmse of each and return matrix with results
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

  % Make plot
  surf(spatialParams, temporalParams, resultsMatrix)
  xlabel('spatial')
  ylabel('temporal')
end
