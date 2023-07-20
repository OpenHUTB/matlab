function obj=parenAssign(obj,indexOp,varargin)










    idx=indexOp(1).Indices;



    if numel(indexOp)>1
        rhsVector=obj(idx{:});
        rhsVector.(indexOp(2:end))=varargin{1};
    else
        rhsVector=varargin{1};
    end



    if~isa(rhsVector,'optim.problemdef.OptimizationValues')
        ME=MException('optim_problemdef:OptimizationValues:indexing:CanOnlyAssignOptimizationValues',...
        getString(message('optim_problemdef:OptimizationValues:indexing:CanOnlyAssignOptimizationValues')));
        throwAsCaller(ME);
    end

    try
        checkSameProperties(obj,rhsVector);
    catch ME
        throwAsCaller(ME);
    end


    sub=substruct('()',idx);
    try
        indexNames=cell(1,2);
        [outSize,valsIdx,~,subOutSize]=...
        optim.internal.problemdef.indexing.getSubsasgnOutputs(sub,size(obj),indexNames);


        idxSingleton=true(1,numel(outSize));
        idxSingleton(2)=false;
        if any(outSize(idxSingleton)>1)


            optim.internal.problemdef.indexing.convertStringToNumericIdx(sub,size(obj),{});
        end


        linearIndexing=true;
        optim.internal.problemdef.indexing.checkValidRHSForSubsasgn(subOutSize,size(rhsVector),linearIndexing);

    catch ME
        if strcmp(ME.identifier,'shared_adlib:operators:BadSubscript')




            ME=MException('optim_problemdef:OptimizationValues:indexing:BadSubscript',...
            getString(message('optim_problemdef:OptimizationValues:indexing:BadSubscript')));
        end
        throwAsCaller(ME);
    end


    numValsIdx=numel(valsIdx);
    isScalarExpansion=numValsIdx>1&&isscalar(rhsVector);


    fnames=properties(obj);
    for i=1:numel(fnames)

        thisField=fnames{i};


        lhsData=obj.Values.(thisField);
        rhsData=rhsVector.Values.(thisField);


        idxSpec=cell(1,ndims(lhsData));
        idxSpec(1:end-1)={':'};
        idxSpec(end)={valsIdx};
        if isScalarExpansion
            rhsIdxSpec=idxSpec;
            rhsIdxSpec{end}=ones(1,numValsIdx);
            rhsData=rhsData(rhsIdxSpec{:});
        end


        lhsData(idxSpec{:})=rhsData;
        obj.Values.(thisField)=lhsData;
    end


    obj.NumValues=outSize(2);

end
