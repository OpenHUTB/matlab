



function tf=validateVoxelLabelData(datum)

    tf=isempty(datum)||(ischar(datum)&&isvector(datum));
end
