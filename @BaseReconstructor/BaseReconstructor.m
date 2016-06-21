classdef BaseReconstructor < handle
  properties (Constant)
    BETA_SQUARED = 1e-8;
    STEP_SIZE = 0.5;
    N_ITERATIONS = 70;
    % These methods are scale sensitive so we arbitrarily rescale the image so
    % that the max value is 4 for consistency's sake
    MAGIC_SCALE_NUMBER = 4;
  end
  properties
    kSpaceInput
    fftObject
    Weights
    imageInput
    nIterations
    debug
    stepSize
    scaleFactor
    imageEstimate
    finalImage
  end
  methods
    function self = BaseReconstructor(kSpaceInput, fftObj, Opts)
      self.kSpaceInput = single(kSpaceInput);
      self.fftObject = fftObj;
      self.Weights = Opts.Weights;

      % TODO: Make this dynamic given defaults from constants
      if isfield(Opts, 'nIterations')
        self.nIterations = Opts.nIterations;
      else
        self.nIterations = self.N_ITERATIONS;
      end

      if isfield(Opts, 'stepSize')
        self.stepSize = Opts.stepSize;
      else
        self.stepSize = self.STEP_SIZE;
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
      self.unscale_image();
      finalImage = self.finalImage;
    end

    function create_image_input(self)
      self.imageInput = self.fftObject' * self.kSpaceInput;
    end

    function scale_image_input(self)
      maxIntensity = max(abs(self.imageInput(:)));
      self.scaleFactor = self.MAGIC_SCALE_NUMBER / maxIntensity;
      self.imageInput = single(self.imageInput * self.scaleFactor);
    end

    function iteratively_reconstruct(self)
      % Pre-allocate imageEstimate and other subclass variables
      self.imageEstimate = self.imageInput;
      self.pre_allocate_loop_variables();

      % Loop for nIterations
      for iIteration = 1:self.nIterations
        % run subclass constraints code, should modify `imageEstimate` field
        % on each iteration
        self.apply_constraints(iIteration);
        % run subclass debug in loop code
        if self.debug
          self.debug_in_loop(iIteration);
        end
      end
    end

    function unscale_image(self)
      self.finalImage = self.imageEstimate ./ self.scaleFactor;
    end
    % end of superclass functions
    % The following are empty functions which can be overwritten in subclasses
    % or just left here to do nothing
    function pre_allocate_loop_variables();
    end
    function apply_constraints(iIteration)
    end
    function update_image_estimate(iIteration)
      % This function should provide or modify a previously
      % provided self.ImageEstimate
      self.imageEstimate = 1;
    end
    function debug_in_loop(iIteration)
    end
  end
end
