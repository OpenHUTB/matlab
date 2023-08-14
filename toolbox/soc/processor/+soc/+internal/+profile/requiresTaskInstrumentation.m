function out=requiresTaskInstrumentation(modelname)
    if bdIsLoaded(modelname)&&codertarget.target.isCoderTarget(modelname)
        out=isequal(get_param(modelname,'CodeExecutionProfiling'),'on');
    else
        out=false;
    end
end