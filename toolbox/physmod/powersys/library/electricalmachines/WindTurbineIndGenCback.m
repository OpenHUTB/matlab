function WindTurbineIndGenCback(Block)





    aMaskObj=Simulink.Mask.get(Block);
    TurbineTabControl=aMaskObj.getDialogControl('Turbine');
    switch get_param(Block,'ExternalTm')
    case 'on'
        TurbineTabControl.Visible='off';
    case 'off'
        TurbineTabControl.Visible='on';
    end