function result=isPortMultiDimensional(Dimension)





    if nargin>0
        Dimension=convertStringsToChars(Dimension);
    end

    if isStringScalar(Dimension)
        Dimension=char(Dimension);
    end

    if ischar(Dimension)
        Dimension=str2num(Dimension);%#ok<ST2NM>
    end

    if isscalar(Dimension)
        if Dimension>1
            result=true;
        else
            result=false;
        end
    elseif isvector(Dimension)

        result=true;

    else
        result=false;

    end

end

