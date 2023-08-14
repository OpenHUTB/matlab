function[H,A,b]=extractQuadraticCoefficients(obj,TotalVar)









    nElem=numel(obj);
    visitor=optim.internal.problemdef.visitor.ExtractQuadraticCoefficients(obj.Variables,TotalVar,nElem);

    visitForest(visitor,obj);

    [H,A,b]=getOutputs(visitor);

end
