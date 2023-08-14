function v=validateBlock(this,hC)%#ok<INUSD> 



    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;

    modType=get_param(bfp,'modType');
    if~(strcmpi(modType,'SPWM: sinusoidal PWM')||strcmpi(modType,'SVM: space vector modulation'))
        errorStatus=1;
        errorMsg=modType;
        v(end+1)=hdlvalidatestruct(errorStatus,message('mcb:blocks:HdlNotSupportedPWMRef',errorMsg));
    end
end