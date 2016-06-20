# FindParams

The FindParams object is used in conjunction with Critter methods to find the best weight parameters for those methods (spatial and temporal TV regularization weights in the case of STCR for example).

This object is initialized with two arguments. `Data` which is the struct of data to be constructed and `bestImage` which is the comparison image(s) which Critter is trying to recreate using `Data`.

The `Data` struct should be suited to the method you are using (see the docs in those methods for explanations and examples). The "best" image should match the result of `Critter.use_*(Data, args)` in terms of dimensionality. For convenience, FindParams can use `Critter`'s sum of squares to combine a multi-coil dataset for comparison if that makes more sense for your application.

For example, if I have a 72 ray dataset and I reconstruct it like so:

```matlab
multiCoilImage = Critter.use_stcr(Data, Opts);
```

Then I can downsample it to 24 rays

```matlab
Data24 = Data.kSpace(:,1:3:72,:,:);
```

and then find spatial and temporal weights that are best able to reconstruct the 24 ray dataset like so:

```matlab
findParamsObj = FindParams(Data24, multiCoilImage);
BestWeights = findParamsObj.find_best_stcr(Weights);
```

(I'll say more on `find_best_stcr` and its relatives in a minute.)

If you wanted to train `FindParams` on the combined image instead of the multi-coil image then you can pass in an option like so:

```matlab
multiCoilImage = Critter.use_stcr(Data, Opts);
finalImage = Critter.sum_of_squares(multiCoilImage);
Data24 = Data.kSpace(:,1:3:72,:,:);

Opts.sumOfSquares = true;
findParamsObj = FindParams(Data24, multiCoilImage, Opts);
% . . .
```


## Parameter Finding Methods

The (current) methods are `find_best_scr` and `find_best_stcr`. They both only require one argument: an initial struct of `Weights` suited to the method you are using (e.g. `Weights.fidelity` `Weights.temporal` and `Weights.spatial` for STCR).

Additionally options can be passed in to customize the reconstruction and the minimization process. These options should be in the fields "Recon" and "Minimization". Whatever is given here will be passed on, unaltered to the minimization and reconstruction algorithms.

That means if I do the following:

```matlab
Opts.Recon.stepSize = 0.25;
findParamsObj.find_best_stcr(Weights, Opts);
```

Then the internal call of `Critter.stcr` will look like this `Critter.use_stcr(Data, Opts.Recon)`.

The minimization Opts can be created using MATLAB's `optimset` function since internally `find_best_*` uses `fminsearch`. Here's an example of using both kind of options when searching for best parameters:

```matlab
Weights.temporal = 0.1;
Weights.spatial = 0.05;
Opts.Recon.stepSize = 0.25;
Opts.Minimization = optimset('Display','iter');
BestWeights = findParamsObj.find_best_stcr(Weights, Opts);
```

The returned value is a struct like the Weights struct, e.g.

```
BestWeights =
  spatial: 0.0231;
  temporal: 0.0893;
```

## ROI

FindParams works by minimizing the root mean square error (RMSE) between the "best" image and the image created at each iteration of the search algorithm. If you would rather use the RMSE of a region of interest (ROI) then you can pass into the object two options specifying the ROI via `Opts.roiRows` and `Opts.roiCols` which will determine the rows and columns of the matrix (image) that are used for RMSE comparison.

For example

```matlab
Opts.roiRows = 25:65;
Opts.roiCols = 67:102;
findParamsObj = FindParams(Data24, multiCoilImage, Opts);
```

## Recap

So to recap, you create a `FindParams` object giving it the data to reconstruct, a "best" image, and any options to pass in. Next you invoke your "find_best_*" method and pass in any options you choose to reconstruction and minimization.
