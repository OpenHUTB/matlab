function[type,storedValue]=localGetTypeAndValue(stValue,typeValue)










    stValue=strtrim(stValue);

    storedValue.options={};

    if~isempty(typeValue)
        type=localGetTypeFromName(typeValue);
        storedString=stValue;
    else

        val=str2double(stValue);
        if~isnan(val)
            if val==-1
                type='Inherited';
            elseif val==0
                type='Continuous';
            elseif val==Inf
                type='Auto';
            elseif val>0
                type='Periodic';
            else
                type='Unresolved';
            end
        else










            matches=regexp(stValue,...
            '^\[\s*([\w.-]+)(\s*[,;]\s*|\s+)[\w.-]+\s*]$','tokens','once');
            if~isempty(matches)&&...
                str2double(matches{1})>0&&...
                ~isinf(str2double(matches{1}))
                type='Periodic';
            else
                type='Unresolved';
            end
        end
        storedString=stValue;
    end


    storedValue.string=storedString;

end
