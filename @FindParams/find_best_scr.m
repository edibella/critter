function Weights = find_best_scr(self, Weights, Opts)
  % Handle missing Opts
  if nargin < 3
    Opts = struct;
  end
  Opts = self.init_opts_struct(Opts);

  % fire up fminsearch
  spatialWeight = Weights.spatial;
  functionHandle = @(weightArg) scr_param_rmse(self, weightArg, Opts.Recon);
  spatialWeight = fminsearch(functionHandle, spatialWeight, Opts.Minimization);

  %  put back into struct
  Weights.spatial = spatialWeight;
end

% Private Methods

function difference = scr_param_rmse(self, spatialWeight, Opts)
  % Default fidelity weight
  if ~isfield(Opts, 'Weights') | ~isfield(Opts.Weights, 'fidelity')
    Opts.Weights.fidelity = 1;
  end

  % Load new weight into Opts struct
  Opts.Weights.spatial = spatialWeight;

  % Reconstruct with parameter and number of iterations
  imageVolume = Critter.use_scr(self.Data, Opts);

  % Use combined image if specified
  if self.Opts.sumOfSquares
    imageVolume = Critter.sum_of_squares(imageVolume);
  end

  % Get RMSE difference between this image and best image.
  difference = self.rmse(imageVolume);
end
