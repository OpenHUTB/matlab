function userAddedPaths=getUserAddedPathEntries()




    cellPath=strsplit(path,pathsep)';

    rootsToRemove={matlabroot};

    toRemove=false(size(cellPath));

    if ispc






        comparisonFcn=@strncmpi;
    else
        comparisonFcn=@strncmp;
    end

    for n=1:length(rootsToRemove)
        thisRoot=rootsToRemove{n};


        toRemove=toRemove|comparisonFcn(cellPath,thisRoot,numel(thisRoot));
    end

    userAddedPaths=cellPath(~toRemove);
end
