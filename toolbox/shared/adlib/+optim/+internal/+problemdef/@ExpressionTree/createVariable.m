function createVariable(obj,VariableImpl,varHandle)












    obj.Depth=1;


    obj.Stack={VariableImpl};

    VariableImpl.StackLength=1;


    obj.Type=optim.internal.problemdef.ImplType.Linear;


    obj.Variables=struct(VariableImpl.Name,varHandle);

end
