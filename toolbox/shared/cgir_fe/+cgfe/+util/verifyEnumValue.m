function aEnumValue=verifyEnumValue(aPropName,aStrValue,aEnumValue)



    aStrValue=convertStringsToChars(aStrValue);
    aEnumValue=convertStringsToChars(aEnumValue);

    if ischar(aEnumValue)
        if~ismember(aEnumValue,aStrValue)
            me=MException('Simulink:tools:CGFEPropertyValueNotEnumString',...
            message('Simulink:tools:CGFEPropertyValueNotEnumString',...
            aPropName));
            me.throw();
        end

    elseif isnumeric(aEnumValue)
        aEnumValue=cgfe.util.verifyInt32Value(aPropName,aEnumValue);
        aEnumValue=cgfe.util.verifyValue(aPropName,(0:numel(aStrValue)-1),aEnumValue);
    else
        cgfe.util.verifyValue(aPropName,0,int32(1));
    end

end


