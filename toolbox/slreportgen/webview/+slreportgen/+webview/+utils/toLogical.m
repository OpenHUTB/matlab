function tf=toLogical(in)



    if isstring(in)
        in=char(in);
    end

    if ischar(in)
        switch lower(in)
        case{'yes','on','true'}
            tf=true;
        case{'no','off','false'}
            tf=false;
        otherwise
            error('Can not convert to boolean');
        end
    else
        tf=logical(in);
    end

end