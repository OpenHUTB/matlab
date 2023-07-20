function obj=createNew(obj,name,dims,idxnames)















    obj.VariableImpl=optim.internal.problemdef.VariableExpressionImpl(...
    char(name),dims);

    createVariable(obj.OptimExprImpl,obj.VariableImpl,obj);


    obj.IndexNames=idxnames;
