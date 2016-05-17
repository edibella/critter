function sum_of_squares_tests(Tester)
  % Load result of other test to use as example data
  % `officialResult`
  load('scr_result.mat')
  inputData = officialResult;

  % Combine via sum of squares
  presentResult = Critter.sum_of_squares(inputData);
  % Load official Result and compare
  load('sum_of_squares_result.mat');
  Tester.test(officialResult, presentResult, 'Test sum_of_squares')
end
