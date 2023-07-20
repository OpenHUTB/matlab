function[status,dscr]=hasAttachedPLCCoder(cs,~)




    dscr='';
    if isa(cs,'Simulink.ConfigSet')
        plc=~isempty(cs.getComponent('PLC Coder'));
    else
        plc=isa(cs,'PLCCoder.ConfigComp');
    end
    if plc
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.InAccessible;
    end


