

function tf=validatePixelLabelData(datum)

    tf=isempty(datum)||(ischar(datum)&&isvector(datum));
end