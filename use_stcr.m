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

  % STCR is a 3D method, so first reshape to 4D
  cartSize = Data.cartesianSize;
  nFrames = prod(cartSize(4:end));

  % Pre-allocate imageOutput
  nRows = Data.cartesianSize(1);
  nCols = Data.cartesianSize(2);
  nTimes = Data.cartesianSize(3);
  imageOutput = zeros(nRows, nCols, nTimes, nFrames);

  % Obtain fftObj from Data, outside the loop
  fftObj = Data.fftObj;

  % Reconstruct each 3D slice of kSpace into a 3D image
  for iFrame = 1:nFrames
    kSpaceFrame = Data.kSpace(:,:,:,iFrame);
    scrObj = Critter.Stcr(kSpaceFrame, fftObj, Opts);
    imageOutput(:,:,:,iFrame) = scrObj.reconstruct();
  end

  % Finally, reshape to original size
  imageOutput = reshape(imageOutput, cartSize);
end
