# Using SCR and STCR

Spatio-Temporally Constrained Reconstruction (STCR) and Spatially Constrained Reconstruction (SCR) are single-coil reconstruction methods that reconstruct static (SCR) and dynamic (STCR) data using iterative TV regularization. More information about the general idea can be found in the paper introducing STCR: <<INSERT SOURCE>>.

Critter supports reconstruction with these iterative methods via the `use_scr` and `use_stcr` methods.

Both methods require you to input a Data struct and an `Opts` struct. The Data struct requires that you supply the following fields:

* `kSpace` - This is the k-space data you are trying to reconstruct. For SCR the data is treated as a volume of 2D static images. Say for example that you have 144 readout points, 30 rays, 8 coils, and 4 slices. Then your data matrix will have dimensions 144 x 30 x 8 x 4. SCR will simply go through each 144 x 30 slice and reconstruct it, iterating through the other dimensions. STCR on the other hand assumes there is a temporal component as well, so it will instead iterate through the first three dimensions, treating the first 2 dimensions as the image data and the third as iterating through time frames.


* `fftObj` - Because the k-space data may or may not be Cartesian, you must supply an object which will transform `kSpace` into a volume of Cartesian images upon multiplication. The `FftTools` package contains such objects in the form of `MultiNufft` and `MaskFft`.

* `cartesianSize` - Again, because k-space may be non Cartesian, you must specify the final cartesian size that you wish k-space to be transformed into. Given the 144 x 30 x 8 x 4 example from before, you would specify the final size of the cartesian images as rows x columns x 8 x 4. The number of rows and columns can be anything you choose, it just has to be consistent with the result your `fftObj` will produce. In a future version, this requirement may be removed since it is possible to deduce these values from `kSpace` and `fftObj`, but for now it is more convenient to have the user specify this value.

The `Opts` struct only requires a `Weights` struct which should contain the regularization weights which will be used to reconstruct the images. For SCR the weights are `fidelity` and `spatial`, and for STCR we also require the `temporal` weight.

```matlab
Opts.Weights.fidelity = 1;
Opts.Weights.spatial = 0.1;
Opts.Weights.temporal = 0.01;
imageVolume = Critter.use_stcr(Data, Opts);
```

And ultimately the result is the reconstructed image volume with dimensions specified by `cartesianSize`.
