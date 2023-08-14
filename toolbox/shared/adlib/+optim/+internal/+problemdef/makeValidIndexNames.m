function indexNames=makeValidIndexNames(indexNames,sz)

















    if isempty(indexNames)
        indexNames={{},{}};
    end

    if isempty(indexNames{1})
        indexNames{1}={};
    end
    if isempty(indexNames{2})
        indexNames{2}={};
    end


    nInputNames=numel(indexNames);
    nSizes=numel(sz);
    nDims=max(nInputNames,nSizes);
    sz=[sz,ones(1,nDims-nSizes)];
    indexNames=[indexNames,repmat({{}},1,nDims-nInputNames)];
    trimIdx=3;

    for k=3:nDims
        if isempty(indexNames{k})
            indexNames{k}={};
            if sz(k)~=1
                trimIdx=k+1;
            end
        else
            trimIdx=k+1;
        end
    end




    indexNames(trimIdx:end)=[];