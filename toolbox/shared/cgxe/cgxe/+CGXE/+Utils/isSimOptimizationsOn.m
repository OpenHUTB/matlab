function result=isSimOptimizationsOn(modelName)



    result=strcmpi(get_param(modelName,'SimCompilerOptimization'),'on');

