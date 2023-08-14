function[valid,values,labels]=getEnumDefintionForValidType(className)
    valid=false;
    values=[];
    labels={};

    if Simulink.data.isSupportedEnumClass(className)
        valid=true;
        [values,labels]=enumeration(className);
        values=real(values);
    end
end

