function varargout=parenReference(obj,indexOp)








    idx=indexOp(1).Indices;


    numIndices=numel(idx);


    sub=substruct('()',idx);
    try
        optim.internal.problemdef.indexing.convertStringToNumericIdx(sub,size(obj),{});
    catch ME
        if strcmp(ME.identifier,'shared_adlib:operators:BadSubscript')




            ME=MException('optim_problemdef:OptimizationValues:indexing:BadSubscript',...
            getString(message('optim_problemdef:OptimizationValues:indexing:BadSubscript')));
        end
        throwAsCaller(ME);
    end


    if numIndices<2
        valsIdx=idx{1};
    else

        valsIdx=idx{2};
    end


    fnames=properties(obj);
    for i=1:numel(fnames)

        thisField=fnames{i};


        thisData=obj.Values.(thisField);


        idxSpec=cell(1,ndims(thisData));
        idxSpec(1:end-1)={':'};
        idxSpec(end)={valsIdx};


        thisData=thisData(idxSpec{:});
        obj.Values.(thisField)=thisData;
    end


    szFirstValue=size(obj.Values.(fnames{1}));
    obj.NumValues=szFirstValue(end);

    if numel(indexOp)==1

        nargoutchk(0,1);


        varargout{1}=obj;
    else

        [varargout{1:nargout}]=obj.(indexOp(2:end));
    end

end

