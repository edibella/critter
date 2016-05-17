function imageOutput = use_scr(Data, Opts)
  % Check Data struct
  requiredFields = { 'kSpace', 'fftObj', 'cartesianSize' };
  Critter.verify_struct(Data, requiredFields, 'Data');

  % Check Opts struct
  requiredFields = { 'Weights' };
  Critter.verify_struct(Opts, requiredFields, 'Opts');

  % Check Opts.Weights struct
  requiredFields = { 'spatial', 'fidelity' };
  Critter.verify_struct(Opts.Weights, requiredFields, 'Opts.Weights');

  % SCR is a 2D method, so first reshape to 3D
  cartSize = Data.cartesianSize;
	nFrames = prod(cartSize(3:end));

  % Pre-allocate imageOutput
  nRows = Data.cartesianSize(1);
  nCols = Data.cartesianSize(2);
  imageOutput = zeros(nRows, nCols, nFrames);

  % Obtain fftObj from Data, outside the loop
  fftObj = Data.fftObj;

  % Reconstruct each 2D slice of kSpace into a 2D image
  for iFrame = 1:nFrames
    kSpaceFrame = Data.kSpace(:,:,iFrame);
    scrObj = Critter.Scr(kSpaceFrame, fftObj, Opts);
    imageOutput(:,:,iFrame) = scrObj.reconstruct();
  end

  % Finally, reshape to cartesian size
  imageOutput = reshape(imageOutput, cartSize);
end
