function out=isValidParams(in)

    if isempty(in)
        out=0;
        return
    else
        if strfind(in,'.')
            out=0;
        else
            out=(all(abs(in)>=abs('0'),1)&all(abs(in)<=abs('9')));
            out=out(1);
        end
    end
end