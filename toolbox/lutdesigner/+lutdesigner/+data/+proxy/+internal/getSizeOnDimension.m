function sz=getSizeOnDimension(value,dimensionIndex)
    if isvector(value)
        sz=numel(value);
    else
        sz=size(value,dimensionIndex);
    end
end
