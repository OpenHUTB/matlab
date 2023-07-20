function[csc,portDims,dimsMode]=getPortProperties(portInfo,inpH,outpH)













    isInport=true;
    if strcmp(portInfo.SLObjectType,'Inport')
        portH=inpH(portInfo.PortNum+1);
    else
        isInport=false;
        portH=outpH(portInfo.PortNum+1);
    end

    blockType=get_param(portH,'BlockType');
    isCtrlPort=false;
    switch(blockType)
    case{'EnablePort','TriggerPort'}
        isCtrlPort=true;
    end
    if isCtrlPort
        csc='';
        dimsMode=0;


        thePort=loc_getControlPortHandle(portH);
    else

        portHandles=get_param(portH,'PortHandles');
        if isInport
            bdName=bdroot(get_param(portH,'Parent'));
            if(strcmp(get_param(bdName,'ModelReferenceTargetType'),'NONE'))
                thePort=portHandles.Outport;
            else




                hiddenSS=slInternal('getHiddenRootSubsystemHandle',bdName);
                ssPortHandles=get_param(hiddenSS,'PortHandles');
                ssInport=ssPortHandles.Inport(portInfo.PortNum+1);
                ssInportObj=get_param(ssInport,'Object');
                actSrcInfo=ssInportObj.getActualSrc();
                thePort=actSrcInfo(1);
            end
        else
            thePort=portHandles.Inport;
        end
        csc=get_param(thePort,'CompiledRTWStorageClass');
        if strcmp(csc,'Auto')&&isRootLevelOutport(portH)
            csc=get_param(portH,'RTWStorageClass');
        end

        dimsMode=get_param(thePort,'CompiledPortDimensionsMode');
    end



    dimensions=get_param(thePort,'CompiledPortDimensions');

    if isempty(dimensions)
        dimensions=get_param(portH,'PortDimensions');
        dimensions=regexprep(dimensions,'[\[\],]','');
        portDims=str2num(dimensions);%#ok
    else

        portDims=dimensions(2:end);
    end
end

function ctrlPortH=loc_getControlPortHandle(ctrlPortBlock)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
    ctrlPortH=-1;

    try %#ok
        obj=get_param(bdroot(ctrlPortBlock),'Object');
        hiddenRootSys=obj.getHiddenRootCondExecSystem;




        if(hiddenRootSys==-1)
            return;
        end

        ph=get_param(hiddenRootSys,'PortHandles');
        blockType=get_param(ctrlPortBlock,'BlockType');

        switch(blockType)
        case 'EnablePort'
            ctrlPortH=ph.Enable;

        case 'TriggerPort'
            ctrlPortH=ph.Trigger;

        otherwise
            error('Unknown control port type');
        end
    end
    delete(sess);
end

function isRootOutport=isRootLevelOutport(portH)
    modelHandle=bdroot(portH);
    modelName=get_param(modelHandle,'Name');
    isRootOutport=false;
    if isequal(get_param(portH,'BlockType'),'Outport')&&...
        isequal(modelName,get_param(portH,'Parent'))
        isRootOutport=true;
    end
end


