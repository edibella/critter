# Verify Struct

This tool is evidence that I don't have a nice way to share functions between packages except the MatlabSpec package, because I don't really think it belongs here.

I hope someday to get the MriData package running nicely, this would belong there, but until that day, this will be here.

Anyways, this function takes a struct that holds some kind of data and specifies that certain fields are expected.

### Example

Let's say you want to work on data that has a kSpace and a trajectory. Then your function internally might look like this

```matlab
function result = do_stuff(Data, Opts)
  requiredFields = { 'kSpace', 'trajectory' }
  verify_data_struct(Data, requiredFields, 'Data')
  process_k_space(Data.kSpace);
  process_trajectory(Data.trajectory);
end
```

That is, the function requires:

* The struct to be checked
* A cell array of fields to check existence of
* A descriptive name of the struct so that the error message can be more helpful.
