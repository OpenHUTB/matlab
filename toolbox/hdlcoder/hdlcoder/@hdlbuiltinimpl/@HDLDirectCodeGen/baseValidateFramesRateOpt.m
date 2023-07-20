function v=baseValidateFramesRateOpt(this,hC)





















    v=hdlvalidatestruct;

    roParam=this.getRateOptionsParameter;
    romode=get_param(hC.SimulinkHandle,roParam);

    if isempty(strfind(romode,'multirate'))
        v=hdlvalidatestruct(1,...
        message('hdlcoder:validate:SinglerateNotSupported'));
    end
