function[A,b]=extractLinearCoefficients(obj,TotalVar)









    nElem=numel(obj);
    visitor=optim.internal.problemdef.visitor.ExtractLinearCoefficients(obj.Variables,TotalVar,nElem);

    visitForest(visitor,obj);

    [A,b]=getOutputs(visitor);

end
