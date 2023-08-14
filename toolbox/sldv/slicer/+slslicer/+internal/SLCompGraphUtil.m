




classdef SLCompGraphUtil<handle








    methods(Static)
        function out=Instance()

            import slslicer.internal.*
            persistent obj;
            if isempty(obj)||~isvalid(obj)
                obj=SLCompGraphUtil;
            end
            out=obj;
        end
    end

    methods


        function outP=findSrcPortsForInport(~,p)

            l=get(p,'Line');
            if l>0
                outP=get(l,'SrcPortHandle');
            else

                bh=get(p,'ParentHandle');
                bd=bdroot(bh);



                if any(strcmp(get(bd,'SimulationStatus'),{'paused','compiled'}))
                    bo=get(bh,'Object');


                    if bo.isSynthesized

                        portNumber=get(p,'PortNumber');
                        po=get(bo.PortHandles.Inport(portNumber),'Object');
                        outP=po.getGraphicalSrc;




                        bo=get(get(outP,'ParentHandle'),'Object');
                        if isa(bo,'Simulink.SubSystem')&&...
                            bo.isSynthesized
                            pn=get(outP,'PortNumber');
                            op=getOutportBlock(bo,pn);
                            portHandles=get(op,'PortHandles');
                            po=get(portHandles.Inport,'Object');
                            outP=po.getGraphicalSrc;
                        end
                    else
                        outP=[];

                    end
                else
                    error('SE:NotCompiled',...
                    getString(message('Sldv:ModelSlicer:ModelSlicer:ModelIsNotIn')));
                end
            end
        end









        function inP=findSrcPortsForOutport(~,p)
            b=get(p,'ParentHandle');
            inP=findSrcPortsForBlock(b,p);
        end









        function outP=findDstPortsForInport(obj,p)
            b=get(p,'ParentHandle');
            outP=findDstPortsForBlock(obj,b,p);
        end



        function inP=findDstPortsForOutport(~,p)
            line=get(p,'Line');
            if~isempty(line)&&line>0
                inP=get(line,'DstPortHandle');
            else

                inP=[];
            end
        end

        function newhandles=...
            walk_through_hiddenbuf(~,oldhandles,oldport_handles)


            newhandles=[];

            for i=1:length(oldhandles)
                walkHandle=oldhandles(i);
                walkObj=get(walkHandle,'Object');
                synthesized=walkObj.isSynthesized;
                type=get(walkHandle,'BlockType');
                if synthesized&&strcmpi(type,'SignalConversion')

                    porthandles=get(walkHandle,'PortHandles');

                    outPort=get(porthandles.Outport,'Object');
                    actdst=outPort.getActualDst;
                    newhandles=[newhandles;actdst(:,1)];
                else
                    newhandles=[newhandles;oldport_handles(i)];
                end
            end
        end


        function yesno=isMatlabFunction(~,bh)
            yesno=strcmp(get(bh,'Type'),'block')&&...
            strcmp(get(bh,'BlockType'),'SubSystem')&&...
            strcmp(get(bh,'SFBlockType'),'MATLAB Function');
        end


        function yesno=blockIsStateflow(~,bh)

            if strcmp(get(bh,'Type'),'block')&&...
                strcmp(get(bh,'BlockType'),'SubSystem')
                yesno=~strcmpi(get(bh,'SFBlockType'),'NONE');
            else
                yesno=false;
            end
        end



        function yesno=blockIsChildOfStateflow(this,bh)
            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            blk=get(bh,'Object');
            sys=blk.getCompiledParent;
            yesno=blockIsStateflow(this,sys);
        end


        function yesno=blockIsStateflowSFunction(this,bh)
            yesno=strcmp(get(bh,'BlockType'),'S-Function')&&...
            this.blockIsChildOfStateflow(bh);
        end

        function chart=sfcnToStateflowBlock(~,bh)
            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            blk=get(bh,'Object');
            sysH=blk.getCompiledParent;
            if strcmp(get(sysH,'SFBlockType'),'Chart')
                chartId=sfprivate('block2chart',sysH);
                chart=idToHandle(sfroot,chartId);
            else
                chart=[];
            end
        end


        function ports=findSrcPortsInChildren(~,bh,ph)
            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            bt=get(bh,'BlockType');
            assert(strcmp(bt,'SubSystem')||strcmp(bt,'ModelReference'));
            inP=findSrcPortsForBlock(bh,ph);
            pO=get(inP,'Object');
            actSrcs=pO.getActualSrc;
            ports=actSrcs(:,1);
        end

        function ports=findDstPortsInChildren(obj,bh,ph)
            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            bt=get(bh,'BlockType');
            assert(strcmp(bt,'SubSystem')||strcmp(bt,'ModelReference'));
            outP=findDstPortsForBlock(obj,bh,ph);
            pO=get(outP,'Object');
            actDsts=pO.getActualDst;
            ports=actDsts(:,1);
        end

        function[yesno,mdlBH]=isSynthesizedSysForMdl(~,bh)
            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            sysO=get(bh,'Object');
            if isa(sysO,'Simulink.SubSystem')&&sysO.isSynthesized&&...
                strcmp(sysO.getSyntReason,...
                'SL_SYNT_BLK_REASON_FCNCALL_MODELREF')
                yesno=true;
                mdlBH=sysO.getOriginalBlock;
            else
                yesno=false;
                mdlBH=-1;
            end

        end

        function bH=getFromWksForSigBuilder(~,sigBldr)
            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            obj=get(sigBldr,'Object');
            hdls=obj.getCompiledBlockList;
            bH=-1;
            for i=1:length(hdls)
                o=get(hdls(i),'Object');
                if isa(o,'Simulink.FromWorkspace')
                    bH=o.Handle;
                    break;
                end
            end
            assert(bH>1);
        end

        function blks=getNVBlocksUnderMask(~,h)
            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            sys=get(h,'Object');
            assert(isa(sys,'Simulink.SubSystem'));
            bh=sys.getCompiledBlockList;
            rti=get(bh,'RuntimeObject');
            if~isempty(rti)
                isNV=cellfun(@(x)~isempty(x),rti);
                blks=bh(isNV);
            else
                blks=[];
            end
        end



        function ancestorHandles=getBlockAncestors(~,blocks,blockMaps)


            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            allparentBlks=blockMaps;
            ancestorHandles=[];

            for index=1:length(blocks)
                extraParent=[];
                blkO=get(blocks(index),'Object');

                if isa(blkO,'Simulink.Port')
                    h=get_param(blkO.handle,'ParentHandle');
                    blkO=get(h,'Object');
                end

                currentParent=blkO.getCompiledParent;
                if~currentParent
                    continue;
                end
                pO=get(currentParent,'Object');
                if isa(pO,'Simulink.BlockDiagram')&&allparentBlks.isKey(currentParent)

                    currentParent=allparentBlks(currentParent);
                    pO=get(currentParent,'Object');
                end

                if isa(pO,'Simulink.BlockDiagram')




                    currentParent=[];
                else
                    extraParent=slslicer.internal.SLGraphUtil.getBlockAncestors(currentParent,blockMaps);
                end
                ancestorHandles=[ancestorHandles,currentParent,extraParent];%#ok<AGROW>
            end
        end

    end
end

function inP=findSrcPortsForBlock(b,p)

    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    import slslicer.internal.*
    if strcmp(get(b,'BlockType'),'SubSystem')

        sysO=get(b,'Object');

        if strcmp(sysO.Variant,'on')

            sysO=get_param(sysO.ActiveVariantBlock,'Object');
        end

        op=getOutportBlock(sysO,get(p,'PortNumber'));
        ph=get(op,'PortHandle');
        inP=ph.Inport;
    elseif strcmp(get(b,'BlockType'),'ModelReference')&&...
        strcmp(get(b,'SimulationMode'),'Normal')
        refMdl=get(b,'NormalModeModelName');
        if isnumeric(p)

            p=get(p,'Object');
        end
        portNum=p.PortNumber;
        sysO=get(b,'Object');
        virtualBusOutportInfo=sysO.VirtualBusOutportInformation;
        if~isempty(virtualBusOutportInfo)
            portNum=virtualBusOutportInfo{portNum}.originalPort;
        end
        op=findOutportBlockInReferencedModel(refMdl,portNum);
        ph=get(op,'PortHandle');
        inP=ph.Inport;
    elseif strcmp(get(b,'BlockType'),'Inport')||...
        strcmp(get(b,'BlockType'),'InportShadow')
        inP=SLGraphUtil.getInportInParent(b,true);
    elseif strcmp(get(b,'BlockType'),'From')
        bo=get(b,'Object');
        goto=getGotoBlock(bo);
        inP=goto.PortHandles.Inport;
    else
        ph=get(b,'PortHandles');
        inP=ph.Inport;
    end
end


function outP=findDstPortsForBlock(~,b,p)

    import slslicer.internal.*
    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    if strcmp(get(b,'BlockType'),'SubSystem')


        sysO=get(b,'Object');

        if strcmp(sysO.Variant,'on')

            sysO=get_param(sysO.ActiveVariantBlock,'Object');
        end

        op=getInportBlock(sysO,get(p,'PortNumber'));
        ph=get(op,'PortHandle');
        outP=ph.Outport;
    elseif strcmp(get(b,'BlockType'),'ModelReference')&&...
        strcmp(get(b,'SimulationMode'),'Normal')



        refMdl=get(b,'NormalModeModelName');
        if isnumeric(p)

            p=get(p,'Object');
        end
        portNum=p.PortNumber;
        sysO=get(b,'Object');
        virtualBusInportInfo=sysO.VirtualBusInportInformation;
        if~isempty(virtualBusInportInfo)
            portNum=virtualBusInportInfo{p.PortNumber}.originalPort;
        end
        op=findInportBlockInReferencedModel(refMdl,portNum);
        ph=get(op,'PortHandles');
        outP=ph.Outport;
    elseif strcmp(get(b,'BlockType'),'Outport')


        outP=SLGraphUtil.getOutportInParent(b);
    elseif strcmp(get(b,'BlockType'),'Goto')

        bo=get(b,'Object');
        from=getFromBlock(bo);
        outP=zeros(length(from),1);
        for i=1:length(from)
            outP(i)=from(i).PortHandles.Outport;
        end
    else

        ph=get(b,'PortHandles');
        outP=ph.Outport;
    end
end

function goto=getGotoBlock(bo)

    h=bo.getGraphicalSrc;
    goto=get(h,'Object');
end

function from=getFromBlock(bo)

    h=bo.getGraphicalDst;
    for i=1:length(h)
        if i==1
            from=get(h(i),'Object');
        else
            from(end+1)=get(h(i),'Object');%#ok<AGROW>
        end
    end
end


function op=getOutportBlock(subsys,ii)

    children=subsys.getCompiledBlockList;

    idx=-1;
    for i=1:length(children)
        c=get(children(i),'Object');
        if isa(c,'Simulink.Outport')&&...
            str2double(c.Port)==ii
            idx=i;
            break;
        end
    end
    op=children(idx);
end

function op=getInportBlock(subsys,ii)

    children=subsys.getCompiledBlockList;

    idx=-1;
    for i=1:length(children)
        c=get(children(i),'Object');
        if isa(c,'Simulink.Inport')&&...
            str2double(c.Port)==ii
            idx=i;
            break;
        end
    end
    op=children(idx);
end

function bh=findOutportBlockInReferencedModel(mdl,i)

    function yesno=isOutport(bh,i)
        obj=get(bh,'Object');
        yesno=isa(obj,'Simulink.Outport')&&(str2double(obj.Port)==i);
    end
    mObj=get_param(mdl,'Object');
    sortedList=mObj.getSortedList;
    bh=sortedList(arrayfun(@(x)isOutport(x,i),sortedList));
end

function bh=findInportBlockInReferencedModel(mdl,i)

    function yesno=isInport(bh,i)
        obj=get(bh,'Object');
        yesno=isa(obj,'Simulink.Inport')&&(str2double(obj.Port)==i);
    end
    mObj=get_param(mdl,'Object');
    sortedList=mObj.getCompiledBlockList;
    bh=sortedList(arrayfun(@(x)isInport(x,i),sortedList));
end
