function[sz,nDims]=getTableDimensions(tableData)

    sz=size(tableData);
    nDims=numel(sz);
    if nDims==2&&min(sz)==1
        nDims=1;
    end
end