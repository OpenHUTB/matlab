function z=insertNanInCellArray(y)

    m=cellfun(@(x)size(x,2),y);
    if~isequal(diff(m),zeros(size(diff(m))))
        error(message('antenna:antennaerrors:NoNaNInsertion'));
    end




    z=y(1);
    nanEntry=nan.*(ones(1,m(1)));
    for i=2:numel(y)
        z=[z,{nanEntry},y(i)];
    end

