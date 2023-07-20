


function boundSig=getBoundSignal(modelName,widgetID,isLibWidget)

    boundSig='';
    bindable=utils.getBoundElement(modelName,widgetID,isLibWidget);

    if~isempty(bindable)
        blk=bindable.BlockPath.getBlock(1);
        boundSig.blkName=get_param(blk,'Name');
        boundSig.blk=blk;
        boundSig.blkh=get_param(blk,'handle');
        boundSig.isSignal=1;
        boundSig.opPortIndex=bindable.OutputPortIndex;
        boundSig.signalName=locGetSignalName(boundSig.blkh,boundSig.opPortIndex);
    end
end

function signalName=locGetSignalName(blkh,opPortIndex)
    phs=get_param(blkh,'PortHandles');
    seg=phs.Outport(opPortIndex);
    signalName=get_param(seg,'Name');
    if isempty(signalName)
        signalName=[get_param(blkh,'Name'),':',num2str(opPortIndex)];
    end
end
