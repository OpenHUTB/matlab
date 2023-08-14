function val=visitFunctionWrapper(visitor,fcnWrapper)





    val=cell(1,fcnWrapper.NumArgOut);

    inputs=fcnWrapper.Inputs;
    nInputs=numel(inputs);
    inputVals=cell(1,nInputs);
    for i=1:nInputs
        inputi=inputs{i};

        visitForest(visitor,inputi);

        inputVals{i}=getOutputs(visitor);

        visitor.Head=visitor.Head-1;
    end

    [val{:}]=feval(fcnWrapper.Func,inputVals{:});

end
