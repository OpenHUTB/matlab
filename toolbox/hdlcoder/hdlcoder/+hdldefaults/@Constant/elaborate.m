function hNewC=elaborate(this,hN,hC)


    [cval,vectorParams1D,TunableParamStr,ConstBusName,ConstBusType]=...
    this.getBlockInfo(hC);

    if vectorParams1D==0
        vectorParams1D='off';
    elseif vectorParams1D==1
        vectorParams1D='on';
    end

    isConstZero=isequal(zeros(size(cval)),cval);

    hNewC=pirelab.getConstComp(hN,hC.SLOutputSignals,cval,hC.Name,...
    vectorParams1D,isConstZero,TunableParamStr,ConstBusName,ConstBusType);
end
