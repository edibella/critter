function imageOutput = use_scr(Data, Opts)
  % Check Data struct
  requiredFields = { 'kSpace', 'fftObj', 'cartesianSize' };
  verify_struct(Data, requiredFields, 'Data');

  % Check Opts struct
  requiredFields = { 'Weights' };
  verify_struct(Opts, requiredFields, 'Opts');

  % Check Opts.Weights struct
  requiredFields = { 'spatial', 'fidelity' };
  verify_struct(Opts.Weights, requiredFields, 'Opts.Weights');

  % If multiCoil is true, ensure that a sensitivity map was provided
  if ~isfield(Opts, 'multiCoil')
    Opts.multiCoil = false;
  end

  if Opts.multiCoil & ~isfield(Opts, 'senseMaps')
    error('When Opts.multiCoil is true, you must provide an Opts.senseMaps')
  end

  % Reshape to 3D for single-coil SCR, and 4D for multi-coil SCR
  cartSize = Data.cartesianSize;
  if Opts.multiCoil
    nCoil = cartSize(3);
	  nFrames = prod(cartSize(4:end));
    cartSize(3) = []; % scr will get rid of the coil dimensions in the final
  else
    nFrames = prod(cartSize(3:end));
  end

  % Pre-allocate imageOutput
  nRows = Data.cartesianSize(1);
  nCols = Data.cartesianSize(2);
  imageOutput = zeros(nRows, nCols, nFrames);

  % Obtain fftObj from Data, outside the loop
  fftObj = Data.fftObj;

  % Reconstruct each 2D slice of kSpace into a 2D image
  for iFrame = 1:nFrames
    % Pesky MATLAB, have to split my index access on this
    if Opts.multiCoil
      kSpaceFrame = Data.kSpace(:,:,:,iFrame);
    else
      kSpaceFrame = Data.kSpace(:,:,iFrame);
    end
    scrObj = Critter.Scr(kSpaceFrame, fftObj, Opts);
    imageOutput(:,:,iFrame) = scrObj.reconstruct();
  end

  % Finally, reshape to cartesian size
  imageOutput = reshape(imageOutput, cartSize);
end
