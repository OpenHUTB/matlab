function indexNames=validateIndexNames(indexNames,sz)





























    if~iscell(indexNames)||~isvector(indexNames)
        throwAsCaller(MException(message('shared_adlib:validateIndexNames:MustBeCellVector')));
    end


    indexNames=indexNames(:)';


    nDims=length(sz);
    nInputNames=length(indexNames);




    if nInputNames<nDims
        throwAsCaller(MException(message('shared_adlib:validateIndexNames:MustHaveAtLeastNDimElts')));
    end


    sz=[sz,ones(1,nInputNames-nDims)];


    trimIdx=[];


    for i=1:nInputNames
        if isempty(indexNames{i})

            indexNames{i}={};
            if sz(i)~=1
                trimIdx=i+1;
            end
        else
            try
                indexNames{i}=optim.internal.problemdef.checkSingleDimIndexNames(...
                indexNames{i},sz(i),i);
            catch E
                throwAsCaller(E);
            end
            trimIdx=i+1;
        end
    end


    indexNames(max(3,trimIdx):end)=[];
