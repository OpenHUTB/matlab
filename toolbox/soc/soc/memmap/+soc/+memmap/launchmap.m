function launchmap(obj)

    cs=obj.getConfigSet;
    mdlH=obj.getModel;

    hwBoard=codertarget.data.getParameterValue(cs,'TargetHardware');
    switch hwBoard
    case[codertarget.internal.getTargetHardwareNamesForSoC,...
        'Custom Hardware Board',...
        codertarget.internal.getCustomHardwareBoardNamesForSoC]

    otherwise
        error(message('soc:msgs:BoardNotSupported',hwBoard));
    end

    mmdlg=soc.memmap.findMemMapperDialog(mdlH);

    if~isempty(mmdlg)
        mmdlg.show();
        return;
    end





    configsetDDGTitle=[message('RTW:configSet:titleCp').getString(),' ',getfullname(mdlH),'/Configuration ',message('RTW:configSet:titleStrActive').getString()];
    ddgH=findDDGByTitle(configsetDDGTitle);
    if~isempty(ddgH)&&ddgH.hasUnappliedChanges
        error(message('soc:memmap:ConfigsetHasUnappliedChanges'));
    end

    memoryMapInfo=soc.memmap.MemoryMapInfo(cs);
    memoryMapInfo.scrapeModel(mdlH);

    memoryMap=soc.memmap.getMemoryMap(mdlH);
    if isempty(memoryMap)||isempty(memoryMap.map)
        memoryMapInfo.genAutoMap;
    else

        memoryMapCopy=copy(memoryMap);
        mapcopy=copy(memoryMap.map);
        memoryMapCopy.map=mapcopy;
        memoryMapInfo.setMemMap(memoryMapCopy);
    end
    mmapview=soc.memmap.MemoryMapView(memoryMapInfo);

    mmdlg=DAStudio.Dialog(mmapview);
    cobj=get_param(mdlH,'InternalObject');
    cobj.addlistener('SLGraphicalEvent::CLOSE_MODEL_EVENT',@(~,~)(l_deleteIfExists(mmdlg)));

end

function l_deleteIfExists(mmdlg)
    if isa(mmdlg,'DAStudio.Dialog')
        delete(mmdlg);
    end
end