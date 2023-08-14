function aValue=verifyClassValue(aPropName,aClassname,aValue)



    if~isa(aValue,aClassname)
        me=MException('Simulink:tools:CGFEPropertyValueNotClassOf',...
        message('Simulink:tools:CGFEPropertyValueNotClassOf',...
        aClassname,aPropName));
        me.throw();
    end

end


