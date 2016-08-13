function multi_coil_tests(Tester)
  % Load test data, create needed variables
  % `testData4D`, `testKMask4D`
  load('test_scr_and_stcr_data.mat')

  % Create Data struct from testData4D and testKMask4D
  Data.kSpace = testData4D;
  Data.fftObj = FftTools.MaskFft(testKMask4D);
  Data.cartesianSize = size(testData4D);

  % sum up the time frames and get sense maps
  multiCoilImage = Data.fftObj' * Data.kSpace;
  multiCoilImage = squeeze(sum(multiCoilImage, 3));
  estimator = SenseMapper.MapEstimator(multiCoilImage);
  Opts.senseMaps = estimator.get_maps;

  % Create Weights struct
  Opts.Weights.fidelity = 1;
  Opts.Weights.temporal = 0.1;
  Opts.Weights.spatial = 0.007;

  % Signal that the multi-coil fidelity method should be used
  Opts.multiCoil = true;
  presentResult = Critter.use_stcr(Data, Opts);

  % 1. Test STCR
  % `officialResult`
  load('multi_coil_stcr_result.mat')
  Tester.test(officialResult, presentResult, 'Test multi-coil-stcr')
end
