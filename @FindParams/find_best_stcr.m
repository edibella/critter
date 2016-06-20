function Weights = find_best_stcr(self, Weights, Opts)
  % Handle missing Opts
  if nargin < 3
    Opts = struct;
  end
  Opts = self.init_opts_struct(Opts);

  % fminsearch works with variable vectors, not structs
  weightsArray = [Weights.spatial, Weights.temporal];
  functionHandle = @(weightsArg) stcr_param_rmse(self, weightsArg, Opts.Recon);
  weightsArray = fminsearch(functionHandle, weightsArray, Opts.Minimization);

  % put them back into a struct
  Weights.spatial = weightsArray(1);
  Weights.temporal = weightsArray(2);
end

% Private methods

function difference = stcr_param_rmse(self, weightsArray, Opts)
  % Default fidelity weight
  if ~isfield(Opts, 'Weights') | ~isfield(Opts.Weights, 'fidelity')
    Opts.Weights.fidelity = 1;
  end

  % Load new weights into Opts struct
  Opts.Weights.spatial = weightsArray(1);
  Opts.Weights.temporal = weightsArray(2);

  % Reconstruct with parameter and number of iterations
  imageVolume = Critter.use_stcr(self.Data, Opts);

  % Use combined image if specified
  if self.Opts.sumOfSquares
    imageVolume = Critter.sum_of_squares(imageVolume);
  end

  % Get RMSE difference between this image and best image.
  difference = self.rmse(imageVolume);
end
