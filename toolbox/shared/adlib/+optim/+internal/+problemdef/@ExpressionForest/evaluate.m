function value=evaluate(obj,varVal)











    visitor=optim.internal.problemdef.visitor.Evaluate(varVal,obj.Variables);

    visitForest(visitor,obj);

    value=getOutputs(visitor);


    value=reshape(value,obj.Size);

end
