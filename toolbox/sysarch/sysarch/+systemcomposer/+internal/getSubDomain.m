function retVal=getSubDomain(handleOrCBInfo)






    if isa(handleOrCBInfo,'SLM3I.CallbackInfo')
        activeEditor=handleOrCBInfo.studio.App.getActiveEditor();
        simulinkHandle=activeEditor.blockDiagramHandle;
    else
        simulinkHandle=handleOrCBInfo;
        assert(ishandle(simulinkHandle),'%s is not a valid handle!',simulinkHandle)
    end

    handleType=get_param(simulinkHandle,'Type');
    switch handleType
    case 'block_diagram'
        retVal=get_param(simulinkHandle,'SimulinkSubDomain');
    case 'block'
        if strcmp(get_param(simulinkHandle,'BlockType'),'SubSystem')
            retVal=get_param(simulinkHandle,'SimulinkSubDomain');
        else
            parent=get_param(simulinkHandle,'Parent');
            retVal=get_param(parent,'SimulinkSubDomain');
        end
    otherwise
        retVal=get_param(bdroot(simulinkHandle),'SimulinkSubDomain');
    end
end
