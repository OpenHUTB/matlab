function[status,dscr]=HDL_edalinksinstalled(cs,~)



    dscr='';
    hdl=cs.getComponent('HDL Coder');
    hdltb=hdl.getsubcomponent('hdlcoderui.hdltb');

    if hdltb.edalinksinstalled
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.UnAvailable;
    end
