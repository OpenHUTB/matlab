function connectSignals(this,blocklist,hN)





    if isCommentedThroughSubsystem(this,hN)
        msgObj=message('hdlcoder:engine:CommentedThroughUnsupported',...
        hN.FullPath);
        this.updateChecks(hN.FullPath,'model',msgObj,'Error');
    end


    if isVariantSubsystem(this,hN)

        if strcmpi(get_param(hN.simulinkHandle,'PropagateVariantConditions'),'on')
            msgObj=message('hdlcoder:engine:PropagateVariantConditionsUnsupported',...
            hN.FullPath);
            this.updateChecks(hN.FullPath,'model',msgObj,'Error');
            error(msgObj);
        else
            this.connectVariantSusbsystem(blocklist,hN);
            return;
        end
    end

    if slhdlcoder.SimulinkFrontEnd.isBusExpansionSubsystem(hN.SimulinkHandle)
        this.connectBusExpansionSubsystem(blocklist,hN);
        return;
    end

    for k=1:length(blocklist)
        slbh=blocklist(k);
        if slhdlcoder.SimulinkFrontEnd.isBusExpansionSubsystem(slbh)

            han=get_param(getfullname(slbh),'Handle');
        else
            han=slbh;
        end
        pcon=get_param(han,'PortConnectivity');
        phan=get_param(han,'PortHandles');

        if~blockIsConnected(slbh,pcon,hN)
            continue;
        end

        processPortList(this,slbh,hN,phan,pcon);
    end
end



function processPortList(this,slbh,hN,phan,pcon)

    if~isempty(phan.State)
        portList=[phan.Outport,phan.State];
    else
        portList=phan.Outport;
    end
    numInPorts=numel(phan.Inport);


    typ=get_param(slbh,'BlockType');
    numOutPorts=length(portList);
    for portIdx=1:numOutPorts

        oportHandle=portList(portIdx);
        hsig=this.pirGetSignal(hN,slbh,oportHandle);




        if strcmp(typ,'Inport')
            pnum=str2double(get(slbh,'Port'))-1;
            hsig.addDriver(hN,pnum);
        else
            pnum=portIdx-1;
            hC=hN.findComponent('sl_handle',slbh);
            if~isempty(hC)
                hsig.addDriver(hC,pnum);
            end
        end


        if this.HDLCoder.getParameter('EnableTestpoints')
            if strcmpi(get_param(oportHandle,'Testpoint'),'on')
                hT=hsig.Type;

                if this.HDLCoder.getParameter('BuildToProtectModel')

                    msgObj=message('hdlcoder:validate:ProtectedModelTestpointUnsupported');
                    this.updateChecks(hN.FullPath,'model',msgObj,'Error');
                end

                if hT.isArrayType&&hT.NumberOfDimensions>1

                    msgObj=message('hdlcoder:validate:MatrixTestpointUnsupported');
                    this.updateChecks(hN.FullPath,'model',msgObj,'Error');
                end
                hsig.setTestpoint(true);
            end
        end
        attachReceivers(this,slbh,hN,phan,pcon,numInPorts,oportHandle,portIdx,hsig);
    end
end

function attachReceivers(this,slbh,hN,phan,pcon,numInPorts,oportHandle,portIdx,hsig)


    ctlPorts=getNumCtlPorts(phan);
    startOfOutputs=numInPorts+ctlPorts;


    dstPortInfo=pcon(portIdx+startOfOutputs);


    dstBlks=dstPortInfo.DstBlock;

    dstBlkPortNums=dstPortInfo.DstPort;








    if isempty(dstBlks)
        [dstBlks,dstBlkPortNums]=graphicalDstForUnconnectedBlocks(slbh,oportHandle);
    elseif isOutBusElementPorts(dstBlks)
        [dstBlks,dstBlkPortNums]=getGraphicalDsts(oportHandle);
    end


    for dstBlkIdx=1:length(dstBlks)
        dstBlk=dstBlks(dstBlkIdx);

        if strcmpi(get_param(dstBlk,'commented'),'through')
            if strcmp(hdlfeature('SupportCommentThrough'),'off')
                dstBlk_path=getfullname(dstBlk);
                msgObj=message('hdlcoder:engine:CommentedThroughBlockUnsupported',...
                dstBlk_path);
                this.updateChecks(dstBlk_path,'model',msgObj,'Error');
            else
                pc=get_param(dstBlk,'PortConnectivity');
                ph=get_param(dstBlk,'PortHandles');
                nInport=numel(ph.Inport);
                portId=dstBlkPortNums(dstBlkIdx)+1;
                attachReceivers(this,slbh,hN,ph,pc,nInport,oportHandle,portId,hsig);
            end
            continue;
        end



        typ=get_param(dstBlk,'BlockType');
        if strcmp(typ,'Outport')
            pnum=str2double(get(dstBlk,'Port'))-1;
            hsig.addReceiver(hN,pnum);
        else
            hC=hN.findComponent('sl_handle',dstBlk);
            if isempty(hC)

                try
                    bhan=slInternal('busDiagnostics',...
                    'handleToExpandedSubsystem',dstBlk);
                    hC=hN.findComponent('sl_handle',bhan);
                catch
                    hC=[];
                end
            end
            pnum=dstBlkPortNums(dstBlkIdx);
            if~isempty(hC)&&pnum<hC.NumberOfPirInputPorts
                hsig.addReceiver(hC,pnum);
            end




            if~isempty(hsig)&&hsig.Type.isRecordType&&~isempty(this.BustoVectorBlocks)
                this.markBustoVectorConversion(hsig,dstBlk,pnum+1,hC);
            end
        end
    end
end


function isv=isVariantSubsystem(this,hThisNetwork)
    isv=~strcmp(hThisNetwork.Name,this.SimulinkConnection.System)&&...
    strcmpi(get_param(hThisNetwork.simulinkHandle,'Variant'),'on');
end



function isv=isCommentedThroughSubsystem(this,hThisNetwork)
    isv=false;

    if~strcmpi(get_param(hThisNetwork.SimulinkHandle,'Type'),'block_diagram')
        isv=strcmp(hThisNetwork.Name,this.SimulinkConnection.System)&&...
        strcmpi(get_param(hThisNetwork.SimulinkHandle,'Commented'),'through');
    end
end



function isConnected=blockIsConnected(slbh,pcon,hN)
    slobj=get_param(slbh,'Object');
    if~slobj.isSynthesized
        isConnected=true;
    else
        if length(pcon)==2&&...
            pcon(1).SrcBlock==-1&&...
            isempty(pcon(2).DstBlock)
            if slhdlcoder.SimulinkFrontEnd.isBusExpansionSubsystem(slbh)||...
                slhdlcoder.SimulinkFrontEnd.isBusExpansionBlock(slbh)

                isConnected=isBusConnected(slbh,hN);
            else
                isConnected=false;
            end
        else
            isConnected=true;
        end
    end
end


function hasConnection=isBusConnected(slbh,hN)
    hasConnection=true;
    phan=get_param(slbh,'PortHandles');
    for jj=1:length(phan.Outport)
        opobj=get_param(phan.Outport(jj),'Object');
        gdport=opobj.getGraphicalDst;
        for kk=1:length(gdport)
            gdportnum=get_param(gdport(kk),'PortNumber');
            gdblk=get_param(gdport(kk),'Parent');
            gdblkh=get_param(gdblk,'Handle');
            gdblktp=get_param(gdblkh,'BlockType');
            if~strcmp(gdblktp,'Outport')
                hgdC=hN.findComponent('sl_handle',gdblkh);
                if~isempty(hgdC)
                    hP=hgdC.PirInputPort(gdportnum);
                    existingSig=hP.Signal;
                    if~isempty(existingSig)
                        hasConnection=false;
                        return;
                    end
                end
            end
        end
    end
end


function ctlPorts=getNumCtlPorts(phan)
    ctlPorts=0;
    if~isempty(phan.Enable)
        ctlPorts=ctlPorts+1;
    end
    if isfield(phan,'StateEnable')&&~isempty(phan.StateEnable)
        ctlPorts=ctlPorts+1;
    end
    if~isempty(phan.Reset)
        ctlPorts=ctlPorts+1;
    end
    if~isempty(phan.Trigger)
        ctlPorts=ctlPorts+1;
    end
    if~isempty(phan.Ifaction)
        ctlPorts=ctlPorts+1;
    end
end



function[dstBlks,dstBlkPortNums]=graphicalDstForUnconnectedBlocks(slbh,oportHandle)
    typ=get_param(slbh,'BlockType');
    blk=get_param(slbh,'Object');
    dstBlks=[];
    dstBlkPortNums=[];

    if blk.isSynthesized





        isCompositeInport=strcmp(typ,'Inport')&&...
        strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_COMPOSITE_PORT');
        isBEBlock=slhdlcoder.SimulinkFrontEnd.isBusExpansionBlock(slbh);
        isSubsystemBusExpansion=strcmp(typ,'SubSystem')&&...
        strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION');

        if(isCompositeInport||isBEBlock||isSubsystemBusExpansion)
            [dstBlks,dstBlkPortNums]=getGraphicalDsts(oportHandle);
        end
    end
end


function[dstBlks,dstBlkPortNums]=getGraphicalDsts(oportH)
    opobj=get_param(oportH,'Object');
    dstPorts=opobj.getGraphicalDst;
    dstBlks=[];
    dstBlkPortNums=[];
    for ii=1:numel(dstPorts)


        dstBlkH=get_param(dstPorts(ii),'ParentHandle');
        if dstBlkHasNoOutport(dstBlkH)
            continue;
        end

        dstBlk=get_param(dstPorts(ii),'ParentHandle');
        portNum=get_param(dstPorts(ii),'PortNumber')-1;
        dstBlks=[dstBlks,dstBlk];%#ok<AGROW>
        dstBlkPortNums=[dstBlkPortNums,portNum];%#ok<AGROW>
    end


    [dstBlks,dstBlkPortNums]=bypassSyntheticDsts(dstBlks,dstBlkPortNums);
end





function isBlkWithNoOut=dstBlkHasNoOutport(dstBlkH)
    isBlkWithNoOut=false;
    dstBlkType=get_param(dstBlkH,'BlockType');
    dstBlkObj=get_param(dstBlkH,'Object');
    if dstBlkObj.isSynthesized&&...
        ((strcmp(dstBlkType,'SubSystem')&&...
        strcmp(dstBlkObj.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION'))||...
        strcmp(dstBlkType,'ToAsyncQueueBlock'))
        portHs=get_param(dstBlkH,'PortHandles');
        numOutports=numel(portHs.Outport);
        if numOutports==0
            isBlkWithNoOut=true;
        end
    end
end

function[dstBlks,dstBlkPortNums]=bypassSyntheticDsts(dstBlks,dstBlkPortNums)



    for jj=1:numel(dstBlks)
        dstObj=get_param(dstBlks(jj),'Object');
        typ=get_param(dstBlks(jj),'BlockType');


        if~dstObj.isSynthesized
            continue;
        end





        if strcmp(typ,'SubSystem')&&...
            strcmp(dstObj.getSyntReason,'SL_SYNT_BLK_REASON_FCNCALL_MODELREF')
            dstBlks(jj)=dstObj.getOriginalBlock;
        else
            if isSyntheticBypassedDest(dstBlks(jj))
                phan=get_param(dstBlks(jj),'PortHandles');
                if(numel(phan.Inport)==1)&&(numel(phan.Outport)==1)
                    oportH=phan.Outport;
                    opobj=get_param(oportH,'Object');

                    dstPort=opobj.getGraphicalDst;

                    dstBlks(jj)=get_param(dstPort,'ParentHandle');
                    dstBlkPortNums(jj)=get_param(dstPort,'PortNumber')-1;
                end
            end
        end
    end
end





function syntheticDest=isSyntheticBypassedDest(dstBlk)

    dstObj=get_param(dstBlk,'Object');
    syntheticDest=~strcmp(dstObj.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')||...
    (strcmp(dstObj.BlockType,'SubSystem')&&strncmp(dstObj.Name,'BusConversion_InsertedFor',25));
end



function flag=isOutBusElementPorts(dstBlks)
    flag=false;
    for dstBlkIdx=1:length(dstBlks)
        dstBlk=dstBlks(dstBlkIdx);
        typ=get_param(dstBlk,'BlockType');
        if strcmp(typ,'Outport')
            obj=get_param(dstBlk,'Object');
            if strcmp(obj.IsBusElementPort,'on')
                flag=true;
                return;
            end
        end
    end
end



