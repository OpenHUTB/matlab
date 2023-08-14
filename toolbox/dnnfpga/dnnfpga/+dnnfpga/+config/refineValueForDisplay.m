function[value,fmt]=refineValueForDisplay(inputValue)





    switch(class(inputValue))
    case 'logical'
        fmt='%s%s: %s\n';
        if inputValue
            value='true';
        else
            value='false';
        end

    case 'char'
        fmt='%s%s: ''%s''\n';
        value=inputValue;

    case 'double'
        if isvector(inputValue)&&length(inputValue)>1
            fmt='%s%s: %s\n';
            value=mat2str(inputValue);
        else


            fmt='%s%s: %g\n';
            value=inputValue;
        end

    otherwise
        fmt='%s%s: %s\n';
        value=[class(inputValue),'.',char(inputValue)];

    end

end

