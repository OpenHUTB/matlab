function out=getDim(sizeArray,dim)
    if dim<=numel(sizeArray)
        out=sizeArray(dim);
    else
        out=1;
    end
end