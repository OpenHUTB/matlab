function out=valueTypeConvert(s,type)



    out=s;
    switch type
    case 'boolean'
        if ischar(s)
            switch s
            case{'true','on'}
                out='on';
            case{'false','off'}
                out='off';
            end
        elseif isnumeric(s)
            if s==0
                out='off';
            else
                out='on';
            end
        end
    case{'int','numeric','number'}
        if ischar(s)
            if isempty(s)
                out=0;
            else
                out=str2double(s);
            end
        end
    end

