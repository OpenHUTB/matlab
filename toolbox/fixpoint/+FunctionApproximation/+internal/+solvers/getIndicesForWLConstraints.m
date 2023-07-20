function[indicesWithConstraints,indicesWithoutConstraints]=getIndicesForWLConstraints(numDimensions,options)














    indicesLogical=true(1,numDimensions+1);
    if options.Interpolation=="Nearest"
        indicesLogical(1:numDimensions)=false;
    end
    if options.AUTOSARCompliant
        indicesLogical(1:numDimensions+1)=false;
    end
    indicesWithConstraints=find(~indicesLogical);
    indicesWithoutConstraints=find(indicesLogical);
end
