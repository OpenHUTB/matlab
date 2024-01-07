function aValue=verifyValue(aPropName,aSetOfAllowedValue,aValue)
    if~all(ismember(aValue,aSetOfAllowedValue))
        me=MException('Simulink:tools:CGFEPropertyValueNotInSet',...
        message('Simulink:tools:CGFEPropertyValueNotInSet',...
        aPropName));
        me.throw();
    end

end


