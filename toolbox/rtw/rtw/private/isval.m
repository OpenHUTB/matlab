function output=isval(array,field,value)




    if(isempty(array))
        output=0;
        return;
    end

    if(~isfield(array,field))
        DAStudio.error('RTW:utility:missingField',field);
    end

    if(~isstruct(array))
        DAStudio.error('RTW:utility:invalidArgType','struct');
    end

    for k=1:length(array)
        if(isequal(array(k).(char(field)),value))
            output=1;
            return;
        end
    end
    output=0;
