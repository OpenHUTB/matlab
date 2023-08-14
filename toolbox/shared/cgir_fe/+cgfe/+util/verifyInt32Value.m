function aValue=verifyInt32Value(aPropName,aValue)



    if~isnumeric(aValue)||(double(int32(aValue))~=double(aValue))
        me=MException('Simulink:tools:CGFEPropertyValueNotInt32',...
        message('Simulink:tools:CGFEPropertyValueNotInt32',...
        aPropName));
        me.throw();
    end

    aValue=int32(aValue);

end


