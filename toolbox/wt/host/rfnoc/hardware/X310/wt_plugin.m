function info=wt_plugin
















    info.DeviceName='X310';



    info.Root=fileparts(mfilename('fullpath'));
    info.Package='wt.internal.hardware.rfnoc';
    info.Hidden=false;
    if strcmp(wt.internal.hardware.rfnoc.feature('MCOSDriver'),"on")
        info.Driver='wt.internal.uhd.mcos.device';
    else
        info.Driver='wt.internal.uhd.clibgen.device';
    end
    info.Device=strcat(info.Package,'.',info.DeviceName);
    info.DeviceType='rfnoc';

end
