function obj=parenDelete(obj,indexOp)








    oldSz=size(obj);
    oldIdxNames=cell(1,2);



    idx=indexOp(1).Indices;
    sub=substruct('()',idx);
    [outSize,valsIdx]=optim.internal.problemdef.indexing.getSubsasgnDeleteOutputs(sub,oldSz,oldIdxNames);


    fnames=fieldnames(obj.Values);
    for i=1:numel(fnames)


        thisField=fnames{i};


        lhsData=obj.Values.(thisField);


        idxSpec=cell(1,ndims(lhsData));
        idxSpec(1:end-1)={':'};
        idxSpec(end)={valsIdx};


        lhsData(idxSpec{:})=[];
        obj.Values.(thisField)=lhsData;
    end


    obj.NumValues=prod(outSize);

end
