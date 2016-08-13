function imageOutput = use_stcr(Data, Opts)
  % Check Data struct
  requiredFields = { 'kSpace', 'fftObj', 'cartesianSize' };
  verify_struct(Data, requiredFields, 'Data');

  % Check Opts struct
  requiredFields = { 'Weights' };
  verify_struct(Opts, requiredFields, 'Opts');

  % Check Weights Struct
  requiredFields = { 'temporal', 'spatial', 'fidelity' };
  verify_struct(Opts.Weights, requiredFields, 'Opts.Weights');

  % If multiCoil is true, ensure that a sensitivity map was provided
  if ~isfield(Opts, 'multiCoil')
    Opts.multiCoil = false;
  end

  if Opts.multiCoil & ~isfield(Opts, 'senseMaps')
    error('When Opts.multiCoil is true, you must provide an Opts.senseMaps')
  end

  % STCR is a 3D method and multi-coil STCR is 4D so we reshape as follows
  cartSize = Data.cartesianSize;

  if Opts.multiCoil
    nCoil = cartSize(4);
	  nFrames = prod(cartSize(5:end));
    cartSize(4) = []; % stcr will get rid of the coil dimensions in the final
  else
    nFrames = prod(cartSize(4:end));
  end


  % Pre-allocate imageOutput
  nRows = Data.cartesianSize(1);
  nCols = Data.cartesianSize(2);
  nTimes = Data.cartesianSize(3);
  imageOutput = zeros(nRows, nCols, nTimes, nFrames);

  % Obtain fftObj from Data, outside the loop
  fftObj = Data.fftObj;

  % Reconstruct each 3D slice of kSpace into a 3D image
  for iFrame = 1:nFrames
    % Pesky MATLAB, have to split my index access on this
    if Opts.multiCoil
      kSpaceFrame = Data.kSpace(:,:,:,:,iFrame);
    else
      kSpaceFrame = Data.kSpace(:,:,:,iFrame);
    end
    scrObj = Critter.Stcr(kSpaceFrame, fftObj, Opts);
    imageOutput(:,:,:,iFrame) = scrObj.reconstruct();
  end

  % Finally, reshape to original size
  imageOutput = reshape(imageOutput, cartSize);
end
