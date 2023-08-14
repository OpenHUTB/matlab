function v=validateImplParams(this,hC)



    v=baseValidateImplParams(this,hC);

    v(end+1)=validateEnumParam(this,hC,'DSPStyle',{'on','off','none'});
end
