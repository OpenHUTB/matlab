function aStr=verifyStringValue(aPropName,aStr)



    aStr=convertStringsToChars(aStr);

    if~ischar(aStr)||size(aStr,1)>1
        me=MException('Simulink:tools:CGFEPropertyValueNotString',...
        message('Simulink:tools:CGFEPropertyValueNotString',...
        aPropName));
        me.throw();
    end

end


