function scr_and_stcr_tests(Tester)
  % Test data comes from some gated cardiac perfusion data that has been PCA'd
  % the PreInterpolator package was used to obtain suitable cartesian data and a mask.

  % Load test data, create needed variables
  % `testData4D`, `testKMask4D`
  load('test_scr_and_stcr_data.mat')

  % Create Data struct from testData4D and testKMask4D
  Data.kSpace = testData4D;
  kMaskCoil = testKMask4D(:,:,:,1);
  Data.fftObj = FftTools.MaskFft(kMaskCoil);
  Data.cartesianSize = [288, 288, 7, 3];;

  % Create Weights struct
  Opts.Weights.fidelity = 1;
  Opts.Weights.temporal = 0.1;
  Opts.Weights.spatial = 0.007;

  % 1. Test STCR
  % `officialResult`
  load('stcr_result.mat')
  presentResult = Critter.use_stcr(Data, Opts);
  Tester.test(officialResult, presentResult, 'Test use_stcr')

  % 2. Test SCR
  % 3D data, keep only first time frame in data and trajectory to simulate *that*
  % kind of 3D.
  Data.kSpace = squeeze(testData4D(:,:,1,:));
  mask3D = squeeze(testKMask4D(:,:,1,:));
  kMaskCoil = mask3D(:,:,1);
  Data.fftObj = FftTools.MaskFft(kMaskCoil);
  Data.cartesianSize = [288, 288, 3];

  % `officialResult`
  load('scr_result.mat')
  presentResult = Critter.use_scr(Data, Opts);
  Tester.test(officialResult, presentResult, 'Test use_scr')
end
