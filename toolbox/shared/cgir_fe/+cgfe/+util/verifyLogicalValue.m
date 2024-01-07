function aValue=verifyLogicalValue(aPropName,aValue)
    if~islogical(aValue)&&(aValue~=1)&&(aValue~=0)
        me=MException('Simulink:tools:CGFEPropertyValueNotBool',...
        message('Simulink:tools:CGFEPropertyValueNotBool',...
        aPropName));
        me.throw();
    end

    aValue=logical(aValue);

end


