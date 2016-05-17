function finalImage = sum_of_squares(imageVolume, dimension)
  % By default, sum along last dimension
  if nargin < 2
    dimension = ndims(imageVolume);
  end

  % Square it, sum it, take the square root
  squaredImage = abs(imageVolume.^2);
  summedImage = sum(squaredImage, dimension);
  finalImage = summedImage.^(1/2);
end
