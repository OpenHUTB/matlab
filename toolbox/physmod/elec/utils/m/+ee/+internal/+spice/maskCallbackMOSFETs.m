function maskCallbackMOSFETs(gcb)



    import pm.sli.internal.getMaskParameterRecursive

    s=get_param(gcb,'SeriesChoice');
    if strcmp(s,'Infineon OptiMOS6 40V')
        set_param(gcb,'MaskVisibilities',{'on','on','off','off','off'});
    elseif strcmp(s,'Infineon OptiMOS4 60V')
        set_param(gcb,'MaskVisibilities',{'on','off','on','off','off'});
    elseif strcmp(s,'Infineon OptiMOS5 80V')
        set_param(gcb,'MaskVisibilities',{'on','off','off','on','off'});
    else
        set_param(gcb,'MaskVisibilities',{'on','off','off','off','on'});
    end

    this=gcb;
    impl=[this,'/subcircuit'];

    set_param(this,'LinkStatus','none');
    devices=ee.internal.spice.inventoryMOSFETs;


    seriesParam=getMaskParameterRecursive(this,'SeriesChoice');



    seriesParam.TypeOptions={'Infineon OptiMOS6 40V','Infineon OptiMOS4 60V','Infineon OptiMOS5 80V','Infineon OptiMOST 120V'};
    series=seriesParam.Value;


    optiMOS40vParam=getMaskParameterRecursive(this,'DeviceOptiMOS40V');
    optiMOS40vParam.TypeOptions=devices.Infineon.OptiMOS40V.names;


    optiMOS60vParam=getMaskParameterRecursive(this,'DeviceOptiMOS60V');
    optiMOS60vParam.TypeOptions=devices.Infineon.OptiMOS60V.names;


    optiMOS80vParam=getMaskParameterRecursive(this,'DeviceOptiMOS80V');
    optiMOS80vParam.TypeOptions=devices.Infineon.OptiMOS80V.names;


    optiMOS120vParam=getMaskParameterRecursive(this,'DeviceOptiMOS120V');
    optiMOS120vParam.TypeOptions=devices.Infineon.OptiMOS120V.names;

    if strcmp(series,'Infineon OptiMOS6 40V')
        device=optiMOS40vParam.Value;
        idx=strcmp(devices.Infineon.OptiMOS40V.names,device);
        ComponentChoice=devices.Infineon.OptiMOS40V.paths{idx};
    elseif strcmp(series,'Infineon OptiMOS4 60V')
        device=optiMOS60vParam.Value;
        idx=strcmp(devices.Infineon.OptiMOS60V.names,device);
        ComponentChoice=devices.Infineon.OptiMOS60V.paths{idx};
    elseif strcmp(series,'Infineon OptiMOS5 80V')
        device=optiMOS80vParam.Value;
        idx=strcmp(devices.Infineon.OptiMOS80V.names,device);
        ComponentChoice=devices.Infineon.OptiMOS80V.paths{idx};
    else
        device=optiMOS120vParam.Value;
        idx=strcmp(devices.Infineon.OptiMOS120V.names,device);
        ComponentChoice=devices.Infineon.OptiMOS120V.paths{idx};
    end

    set_param(impl,'SourceFile',ComponentChoice);
    ik=SLBlockIcon.getEffectiveBlockIconKey(impl);
    set_param(this,'MaskDescription',get_param(impl,'MaskDescription'));
    set_param(this,'MaskType','SPICE-Imported MOSFET');
    SLBlockIcon.setMaskDVGIcon(this,ik);

end