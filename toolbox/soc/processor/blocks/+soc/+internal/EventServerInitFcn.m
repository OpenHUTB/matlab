function EventServerInitFcn(blkH,event)




    mdlName=get_param(bdroot(blkH),'Name');
    hCS=get_param(mdlName,'ActiveConfigurationSet');
    if~codertarget.utils.isMdlConfiguredForSoC(hCS)
        error(message('soc:scheduler:NotConfiguredForSOC',mdlName));
    end
    soc.registerEvent(blkH,event);
    soc.registerBlock(blkH,event,'push');
end