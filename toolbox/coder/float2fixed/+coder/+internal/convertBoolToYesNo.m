
function tStr=convertBoolToYesNo(val)
    if isa(val,'char')
        if strcmp(val,'false')
            tStr='No';
        else
            tStr='Yes';
        end
    else
        if val
            tStr='Yes';
        else
            tStr='No';
        end
    end
end
