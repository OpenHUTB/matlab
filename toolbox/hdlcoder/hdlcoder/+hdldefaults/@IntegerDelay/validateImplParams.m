function v=validateImplParams(this,hC)




    v=baseValidateImplParams(this,hC);

    v(end+1)=validateEnumParam(this,hC,'ResetType',{'Default','None'});
    v(end+1)=validateEnumParam(this,hC,'UseRAM',{'on','off'});
end
