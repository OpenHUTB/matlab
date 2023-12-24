function connectMessageToBusSelector(obsPortH)

    if isConnectedToBusSelector(obsPortH)
        return;
    end

    modelName=string(get_param(bdroot(obsPortH),"Name"));
    obsPortPosition=get_param(obsPortH,"Position");
    busPosition=obsPortPosition+[120,-6,80,6];


    busH=add_block("simulink/Signal Routing/Bus Selector",modelName+"/Bus Selector",...
    "MakeNameUnique","on","Position",busPosition);

    obsPH=get_param(obsPortH,"PortHandles");
    busPH=get_param(busH,"PortHandles");
    add_line(modelName,obsPH.Outport,busPH.Inport);

    set_param(busH,"OutputSignals","OrigPayload,Metadata")

    for outport=busPH.Outport
        portPos=get_param(outport,"Position");
        add_line(modelName,[portPos;portPos+[80,0]]);
    end
end


function bool=isConnectedToBusSelector(obsPortH)
    bool=false;
    lineHandles=get_param(obsPortH,"LineHandles");
    if lineHandles.Outport~=-1
        destBlockHandles=get_param(lineHandles.Outport,"DstBlockHandle");
        if destBlockHandles~=-1&&get_param(destBlockHandles,"BlockType")=="BusSelector"

            bool=true;
            return;
        else
            delete_line(lineHandles.Outport);
        end
    end
end
