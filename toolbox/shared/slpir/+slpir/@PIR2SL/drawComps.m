function drawComps(this,tgtParentPath,hN)
    this.genmodeldisp(message('hdlcoder:engine:MsgLayout').getString(),3);

    if(rootNetwork(this,hN))
        addInportBlocks(this,tgtParentPath,hN,~(this.DUTMdlRefHandle>0));
        addOutportBlocks(this,tgtParentPath,hN);
        tgtParentHandle=get_param(tgtParentPath,'handle');
        type=get_param(tgtParentHandle,'Type');
        if strcmp(type,'block')
            markPortsAsTestpoints(this,tgtParentHandle,hN);
        end
    end

    if hN.hasSLHWFriendlySemantics
        addHwFriendlyToken(this,tgtParentPath);
    end

    vComps=hN.Components;
    numComps=length(vComps);

    for i=1:numComps
        hC=vComps(i);
        if hC.getRtwcgDraw
            drawBlockFromUser(this,tgtParentPath,hC);
        elseif hC.shouldDraw
            drawSLBlockFromPirComp(this,tgtParentPath,hC);
        end
    end
end


function markPortsAsTestpoints(~,tgtParentHandle,hN)
    tgtParentPorts=get_param(tgtParentHandle,'PortHandles');
    tgtParentOutports=tgtParentPorts.Outport;
    for ii=1:numel(hN.PirOutputPorts)
        outport=hN.PirOutputPorts(ii);
        if outport.isTestpoint
            portIndex=outport.PortIndex;
            if portIndex~=-1
                set_param(tgtParentOutports(portIndex+1),'Testpoint',1);
            end
        end
    end
end


function result=rootNetwork(~,hN)
    result=hN.isModelgenRootNetwork;
end


function addHwFriendlyToken(~,tgtParentPath)
    slBlockName=[tgtParentPath,'/StateControl'];
    add_block('built-in/StateControl',slBlockName,'StateControl','Synchronous');
end
