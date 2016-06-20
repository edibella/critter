function find_params_tests(Tester)
  % Load test data, create needed variables
  % `testData4D`, `testKMask4D`
  load('test_scr_and_stcr_data.mat')

  % Create Data struct from testData4D and testKMask4D
  % test data is 288 x 288 x 7 time x 3 coil
  Data.kSpace = testData4D;
  kMaskCoil = testKMask4D(:,:,:,1);
  Data.fftObj = FftTools.MaskFft(kMaskCoil);
  Data.cartesianSize = size(testData4D);

  % Create Weights struct
  Opts.Weights.fidelity = 1;
  Opts.Weights.temporal = 0.1;
  Opts.Weights.spatial = 0.007;

  % Other opts
  Opts.nIterations = 10;

  % Create "best" image
  multiCoilImage = Critter.use_stcr(Data, Opts);

  % test finding params from undersampled image
  everyOther = 1:2:288;
  Data144.kSpace = Data.kSpace;
  Data144.kSpace(everyOther,:,:,:) = 0;
  kMask144 = kMaskCoil;
  kMask144(everyOther,:,:) = 0;
  Data144.fftObj = FftTools.MaskFft(kMask144);
  Data144.cartesianSize = size(Data144.kSpace);

  findParamsObj = Critter.FindParams(Data144, multiCoilImage);
  Opts.Recon.nIterations = 10;
  Opts.Minimization = optimset('Display','none','MaxFunEvals', 10); % make a quicker test
  BestWeights = findParamsObj.find_best_stcr(Opts.Weights, Opts);

  % Compare the obtained weights to these hard-coded ones obtained last time this ran correctly - note that order matters for matlab's isequal when comparing structs
  TargetWeights.fidelity = 1;
  TargetWeights.temporal = 0.0975;
  TargetWeights.spatial = 0.006475;
  Tester.test_struct(TargetWeights, BestWeights, 'Test find_best_stcr with opts');

  % Now test using ROI and sum of square opts in object
end
