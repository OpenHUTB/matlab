function[valid,states]=getEnumDefinition(className)
    valid=false;
    states=[];
    if Simulink.data.isSupportedEnumClass(className)
        valid=true;
        [values,labels]=enumeration(className);
        values=real(values);
        states=struct('Label',labels,'Value',num2cell(values));
    end
end

