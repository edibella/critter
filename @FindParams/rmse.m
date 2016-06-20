function result = rmse(self, imageVolume)
  % If roi rows and columns are given in finder opts, use that region only
  if isfield(self.Opts, 'roiRows') & isfield(self.Opts, 'roiCols')
    imageVolumeROI = imageVolume(self.Opts.roiRows,self.Opts.roiCols,:);
    bestImageROI = self.bestImage(self.Opts.roiRows,self.Opts.roiCols,:);
  else
    % Otherwise treat whole thing as ROI
    imageVolumeROI = imageVolume;
    bestImageROI = self.bestImage;
  end

  % Rescale to minimize rmse
  denominator = bestImageROI(:).' * pinv(bestImageROI(:)).'; % should be 1
  newScale = bestImageROI(:).' * pinv(imageVolumeROI(:)).' / denominator;
  imageVolumeROI = imageVolumeROI * newScale;

  % calc rmse
  difference = bestImageROI(:) - imageVolumeROI(:);
  squaredDifference = abs(difference.^2);
  result = sqrt(mean(squaredDifference));
end
