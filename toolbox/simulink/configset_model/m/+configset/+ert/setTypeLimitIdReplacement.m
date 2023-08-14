function newvalue=setTypeLimitIdReplacement(hSrc,value)















    if isempty(value)
        newvalue=value;
        return;
    end


    maxLength=256;
    cs=hSrc.getConfigSet;
    if~isempty(cs)
        if cs.isValidParam('MaxIdLength')
            maxLength=get_param(cs,'MaxIdLength');
        end
    end

    if length(value)>maxLength
        DAStudio.error('Simulink:mpt:MPTTypeIdReplacementExceededMaxLength',...
        num2str(maxLength),value);
    end

    rexpMatch=regexp(value,'[_a-zA-Z][_a-zA-Z0-9]*','match');

    if length(rexpMatch)~=1||~strcmp(rexpMatch,value)
        DAStudio.error('Simulink:mpt:MPTInvalidTypeIdReplacement',value);
    end

    newvalue=value;
