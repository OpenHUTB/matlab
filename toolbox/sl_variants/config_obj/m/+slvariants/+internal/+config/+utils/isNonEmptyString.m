function is=isNonEmptyString(s)




    is=false;
    if~Simulink.variant.utils.isCharOrString(s)
        return;
    end
    s=strtrim(s);
    if~iscell(s)
        [m,~]=size(s);
        is=(m==1);
    end
end
