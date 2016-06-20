classdef FindParams < handle
  properties
    Data
    bestImage
    Opts
    totalIterations
  end
  methods
    % Init class with Data struct for Critter recon, bestImage for comparison, and Opts
    function self = FindParams(Data, bestImage, Opts)
      % Stash variables
      self.Data = Data;
      self.bestImage = bestImage;

      % Opts is an optional argument
      if nargin == 2
        self.Opts = struct;
      else
        self.Opts = Opts;
      end

      % default sum of squares setting
      if ~isfield(self.Opts, 'sumOfSquares')
        self.Opts.sumOfSquares = false;
      end
    end

    % find methods take an opts struct that needs Recon and Minimization fields
    function Opts = init_opts_struct(self, Opts)
      if ~isfield(Opts, 'Recon')
        Opts.Recon = struct;
      end

      if ~isfield(Opts, 'Minimization')
        Opts.Minimization = struct;
      end
    end
  end
end
