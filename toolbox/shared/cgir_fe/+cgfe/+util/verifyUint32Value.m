function aValue=verifyUint32Value(aPropName,aValue)

    if~isnumeric(aValue)||(double(uint32(aValue))~=double(aValue))
        me=MException('Simulink:tools:CGFEPropertyValueNotUInt32',...
        message('Simulink:tools:CGFEPropertyValueNotUInt32',...
        aPropName));
        me.throw();
    end

    aValue=uint32(aValue);

end


