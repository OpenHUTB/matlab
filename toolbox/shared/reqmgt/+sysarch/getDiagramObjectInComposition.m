function item=getDiagramObjectInComposition(model,semanticUUID)


    item=[];
    ph=sysarch.getPortHandleForMarkup(semanticUUID,model);
    if strcmpi(get_param(ph,'type'),'Block')
        blkObj=get_param(ph,'Object');
        portHandles=blkObj.portHandles;
        if~isempty(portHandles.Inport)
            ph=portHandles.Inport;
        else
            ph=portHandles.Outport;
        end
    end
    if~isempty(ph)
        item=diagram.resolver.resolve(ph);
    end

end
