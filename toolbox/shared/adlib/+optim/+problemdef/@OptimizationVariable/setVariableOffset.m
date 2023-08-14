function TotalVar=setVariableOffset(vars)








    varOffset=1;
    fnames=fieldnames(vars);
    for i=1:numel(fnames)
        curVar=vars.(fnames{i});
        setOffset(curVar,varOffset);
        varOffset=varOffset+numel(curVar);
    end




    TotalVar=varOffset-1;
end
