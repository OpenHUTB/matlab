



classdef SLGraphUtil







    methods(Static)
        function outP=findSrcPortsForInport(p)

            import slslicer.internal.*
            l=get(p,'Line');
            if l>0
                outP=get(l,'SrcPortHandle');
                if outP<0
                    outP=[];
                end
            else

                bh=get(p,'ParentHandle');
                bd=bdroot(bh);



                if strcmp(get(bd,'SimulationStatus'),'paused')
                    seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
                    bo=get(bh,'Object');


                    if bo.isSynthesized

                        portNumber=get(p,'PortNumber');
                        po=get(bo.PortHandles.Inport(portNumber),'Object');
                        outP=po.getGraphicalSrc;
                    else
                        outP=[];
                    end
                else

                    outP=[];
                end

            end
        end

        function srcB=findSrcBlocks(bH,compiled)






            import slslicer.internal.*
            ph=get(bH,'PortHandles');
            bt=get(bH,'BlockType');
            if strcmp(bt,'ModelReference')
                error('Model Reference are not supported');
            end

            if strcmp(bt,'SubSystem')&&isempty(get(bH,'MaskType'))
                error('ModelSlicer:GraphUtil:ShouldNotAnalyzeSubSystem',...
                'Unmasked subsystems are not supported');
            end

            if~isempty(ph.Inport)


                srcB=[];
                for i=1:length(ph.Inport)
                    outP=SLGraphUtil.findSrcPortsForInport(ph.Inport(i));
                    srcB=[srcB...
                    ,findVirtualOutportBlockForPort(outP)];%#ok<AGROW>
                end
            else


                bt=get(bH,'BlockType');
                if strcmp(bt,'Inport')||...
                    strcmp(get(bH,'BlockType'),'InportShadow')


                    inP=SLGraphUtil.getInportInParent(bH,compiled);
                    outP=SLGraphUtil.findSrcPortsForInport(inP);
                    srcB=findVirtualOutportBlockForPort(outP);
                elseif strcmp(bt,'From')

                    gotoB=get(bH,'GotoBlock');

                    if~isempty(gotoB)
                        assert(length(gotoB)==1);
                        srcB=gotoB.handle;
                    else
                        srcB=[];
                    end
                elseif strcmp(bt,'EnablePort')
                    enabP=SLGraphUtil.getEnablePortInParent(bH,compiled);
                    outP=SLGraphUtil.findSrcPortsForInport(enabP);
                    srcB=findVirtualOutportBlockForPort(outP);
                else


                    srcB=[];
                end

            end
        end


        function dstB=findDstBlocks(bH)



            import slslicer.internal.*
            bt=get(bH,'BlockType');
            if strcmp(bt,'ModelReference')
                error('ModelReference are not supported');
            end
            if strcmp(bt,'SubSystem')&&isempty(get(bH,'MaskType'))
                error('ModelSlicer:GraphUtil:ShouldNotAnalyzeSubSystem',...
                'Unmasked subsystems are not supported');
            end

            ph=get(bH,'PortHandles');

            if~isempty(ph.Outport)


                dstB=[];

                for i=1:length(ph.Outport)
                    dstP=findDstPortsForOutport(ph.Outport(i));
                    dstB=[dstB,findVirtualInportBlockForPort(dstP)];%#ok<AGROW>
                end
            else


                if strcmp(get(bH,'BlockType'),'Outport')


                    dstP=SLGraphUtil.getOutportInParent(bH);
                    inP=findDstPortsForOutport(dstP);
                    dstB=findVirtualInportBlockForPort(inP);
                elseif strcmp(get(bH,'BlockType'),'Goto')


                    fromB=get(bH,'FromBlock');
                    if~isempty(fromB)
                        dstB=arrayfun(@(x)x.handle,fromB);
                    else
                        dstB=[];
                    end
                else

                    dstB=[];
                end

            end
        end

        function OutP=getOutportInParent(OutportB)

            import slslicer.internal.*
            b=OutportB;
            bo=get(b,'Object');
            if isa(bo.getParent,'Simulink.SubSystem')
                sysH=get_param(bo.Parent,'Handle');
                sysO=get(sysH,'Object');

                if isa(sysO.getParent,'Simulink.SubSystem')
                    sysHP=get_param(bo.Parent,'Handle');
                    sysOP=get(sysHP,'Object');
                    if strcmp(sysOP.Variant,'on')

                        sysO=sysOP;




                        bo=SLGraphUtil.getOutportBlockByName(sysOP,bo.Name);
                    end
                end

                portNumber=str2double(bo.Port);
                OutP=sysO.PortHandles.Outport(portNumber);
            elseif isa(bo.getParent,'Simulink.BlockDiagram')

                mdlName=bo.Parent;


                a=find_system('MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference','ModelName',mdlName);
                if length(a)>1
                    error(getString(message('Sldv:ModelSlicer:ModelSlicer:DontKnowWhatDo')));
                end
                if length(a)==1
                    bh=get_param(a{1},'Handle');
                    mdlBlkO=get(bh,'Object');
                    portNumber=str2double(bo.Port);
                    OutP=mdlBlkO.PortHandles.Outport(portNumber);
                else
                    OutP=[];
                end
            end
        end

        function inP=getInportInParent(inportB,compiled)

            import slslicer.internal.*
            b=inportB;
            bo=get(b,'Object');
            if compiled
                seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

                if isa(bo,'Simulink.InportShadow')
                    parentH=bo.getParent;
                else
                    parentH=bo.getCompiledParent;
                end
                pO=get(parentH,'Object');
            else



                pO=get_param(bo.Parent,'Object');
            end
            if isa(pO,'Simulink.SubSystem')
                sysO=pO;

                if isa(sysO.getParent,'Simulink.SubSystem')
                    sysOP=sysO.getParent;
                    if strcmp(sysOP.Variant,'on')

                        sysO=sysOP;




                        bo=SLGraphUtil.getInportBlockByName(sysOP,bo.Name);
                    end
                end

                portNumber=str2double(bo.Port);
                inP=sysO.PortHandles.Inport(portNumber);

            elseif isa(pO,'Simulink.BlockDiagram')

                mdlName=pO.Name;


                a=find_system('MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType','ModelReference',...
                'ModelName',mdlName,'SimulationMode','Normal');
                if length(a)>1
                    error(getString(message('Sldv:ModelSlicer:ModelSlicer:DontKnowWhatDo')));
                end
                if length(a)==1
                    bh=get_param(a{1},'Handle');
                    mdlBlkO=get(bh,'Object');
                    portNumber=str2double(bo.Port);
                    inP=mdlBlkO.PortHandles.Inport(portNumber);
                else
                    inP=[];
                end
            end
        end

        function inP=getEnablePortInParent(inportB,compiled)

            b=inportB;
            bo=get(b,'Object');
            pO=bo.getParent;
            if isa(pO,'Simulink.SubSystem')
                sysO=pO;

                if isa(sysO.getParent,'Simulink.SubSystem')
                    sysOP=sysO.getParent;
                    if strcmp(sysOP.Variant,'on')

                        sysO=sysOP;
                    end
                end

                inP=sysO.PortHandles.Enable;

            elseif isa(pO,'Simulink.BlockDiagram')

                mdlName=pO.Name;


                a=find_system('MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType','ModelReference',...
                'ModelName',mdlName);
                if length(a)>1
                    error(getString(message('Sldv:ModelSlicer:ModelSlicer:DontKnowWhatDo')));
                end
                if length(a)==1
                    bh=get_param(a{1},'Handle');
                    mdlBlkO=get(bh,'Object');
                    inP=mdlBlkO.PortHandles.Enable;
                else
                    inP=[];
                end
            end
        end


        function objs=getAllSystems(bh)



            n=length(bh);
            parentO=[];
            systemMap=containers.Map('KeyType','double','ValueType','logical');
            for i=1:n
                systemMap(bh(i))=true;
                bhObj=get_param(bh(i),'Object');

                parentO=[parentO;bh(i)];%#ok<AGROW>

                p=bhObj.Parent;
                if isempty(p)

                    continue;
                end
                pO=get_param(p,'Object');

                while~isKey(systemMap,pO.Handle)&&~isa(pO,'Simulink.BlockDiagram')

                    if isa(pO,'Simulink.SubSystem')
                        systemMap(pO.handle)=true;
                    end
                    p=pO.parent;
                    pO=get_param(p,'Object');
                end
            end

            objs=cell2mat(systemMap.keys)';
        end

        function op=getOutportBlock(subsys,i)

            import slslicer.internal.*
            fh=@(x)isa(x,'Simulink.Outport')&&str2double(x.Port)==i;
            op=SLGraphUtil.getBlockMatchingPredicate(subsys,fh);
        end

        function ip=getInportBlock(subsys,i)

            import slslicer.internal.*
            fh=@(x)isa(x,'Simulink.Inport')&&str2double(x.Port)==i;
            ip=SLGraphUtil.getBlockMatchingPredicate(subsys,fh);
        end

        function op=getOutportBlockByName(subsys,name)

            import slslicer.internal.*
            fh=@(x)isa(x,'Simulink.Outport')&&strcmp(x.Name,name);
            op=SLGraphUtil.getBlockMatchingPredicate(subsys,fh);
        end
        function ip=getInportBlockByName(subsys,name)

            fh=@(x)isa(x,'Simulink.Inport')&&strcmp(x.Name,name);
            ip=slslicer.internal.SLGraphUtil.getBlockMatchingPredicate(subsys,fh);
        end

        function obj=getBlockMatchingPredicate(subsys,fh)

            import slslicer.internal.*

            if~isa(subsys,'Simulink.SubSystem')
                subsys=get_param(subsys,'Object');
            end


            if~isempty(subsys.TemplateBlock)
                subsys=subsys.getChildren;
            end
            children=subsys.getChildren;


            filt=arrayfun(@(x)isa(x,'Simulink.Block'),children);
            children=children(filt);

            childrenO=arrayfun(@(x)get(x,'Object'),children,...
            'UniformOutput',false);
            obj=children(cellfun(@(x)fh(x),childrenO));
        end


        function ancestorHandles=getBlockAncestors(blocks,blockMaps)


            allparentBlks=blockMaps;
            ancestorHandles=[];

            for index=1:length(blocks)
                extraParent=[];
                currentParent=get_param(get(blocks(index),'Parent'),'Handle');
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

        function[srcP,dstP]=findSrcDstPairsForSysOutport(bh,ph)
            import slslicer.internal.SLGraphUtil;
            inP=SLGraphUtil.findSrcPortsForOutport(bh,ph);
            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            srcP=[];
            dstP=[];
            for ip=inP'
                pO=get(ip,'Object');
                actSrcs=pO.getActualSrc;
                if isempty(actSrcs)
                    continue;
                end
                sources=actSrcs(:,1);
                [aSrcs,aDsts]=meshgrid(sources,ip);
                srcP=[srcP,reshape(aSrcs,1,[])];%#ok<*AGROW>
                dstP=[dstP,reshape(aDsts,1,[])];
            end
        end

        function ip=findSrcPortsForOutport(bh,ph)


            bt=get(bh,'BlockType');
            pt=get(ph,'PortType');
            assert(strcmp(pt,'outport'));
            assert(strcmp(bt,'SubSystem')||strcmp(bt,'ModelReference'));
            portNum=get(ph,'PortNumber');
            opts=Simulink.FindOptions('SearchDepth',1);
            if strcmp(bt,'SubSystem')
                sys=bh;
            else
                virtualInfo=get(bh,'VirtualbusOutportInformation');
                portNum=virtualInfo{portNum}.originalPort;
                sys=get(bh,'NormalModeModelName');
            end
            outBlk=Simulink.findBlocksOfType(sys,'Outport','Port',num2str(portNum),opts);
            ports=get(outBlk,'PortHandles');
            if iscell(ports)
                ip=cellfun(@(p)p.Inport,ports);
            else
                ip=ports.Inport;
            end
        end

        function[srcP,dstP]=findSrcDstPairsForSysInport(bh,ph)
            import slslicer.internal.SLGraphUtil;
            outP=SLGraphUtil.findDstPortsForInport(bh,ph);
            seas=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            srcP=[];
            dstP=[];
            for op=outP'
                pO=get(op,'Object');
                actDsts=pO.getActualDst;
                if isempty(actDsts)
                    continue;
                end
                destinations=actDsts(:,1);
                [aSrcs,aDsts]=meshgrid(op,destinations);
                srcP=[srcP,reshape(aSrcs,1,[])];%#ok<*AGROW>
                dstP=[dstP,reshape(aDsts,1,[])];
            end
        end

        function op=findDstPortsForInport(bh,ph)


            bt=get(bh,'BlockType');
            pt=get(ph,'PortType');
            assert(strcmp(pt,'inport'));
            assert(strcmp(bt,'SubSystem')||strcmp(bt,'ModelReference'));
            portNum=get(ph,'PortNumber');
            opts=Simulink.FindOptions('SearchDepth',1);
            if strcmp(bt,'SubSystem')
                sys=bh;
            else
                virtualInfo=get(bh,'VirtualbusInportInformation');
                portNum=virtualInfo{portNum}.originalPort;
                sys=get(bh,'NormalModeModelName');
            end
            inBlk=Simulink.findBlocksOfType(sys,'Inport','Port',num2str(portNum),opts);
            ports=get(inBlk,'PortHandles');
            if iscell(ports)
                op=cellfun(@(p)p.Outport,ports);
            else
                op=ports.Outport;
            end
        end
    end
end

function srcB=findVirtualOutportBlockForPort(outP)


    import slslicer.internal.*
    srcB=[];
    for pi=1:length(outP)
        p=outP(pi);
        b=get(p,'ParentHandle');
        if strcmp(get(b,'BlockType'),'SubSystem')&&...
            ~strcmp(get(b,'MaskType'),'Sigbuilder block')
            sysO=get(b,'Object');

            if isempty(sysO.getChildren)
                srcB(end+1)=b;
            else
                opBlk=SLGraphUtil.getOutportBlock(sysO,get(p,'PortNumber'));
                if~isempty(opBlk)
                    if strcmp(sysO.Variant,'on')




                        sysO=get_param(sysO.ActiveVariantBlock,'Object');
                        opBlkName=opBlk.Name;
                        opBlk=SLGraphUtil.getOutportBlockByName(sysO,opBlkName);
                    end
                    if~isempty(opBlk)
                        for j=1:length(opBlk)
                            srcB(end+1)=opBlk(j).handle;
                        end
                    end
                end
            end
        elseif strcmp(get(b,'BlockType'),'ModelReference')


            srcB(end+1)=b;
        elseif strcmp(get(b,'BlockType'),'Inport')
            srcB(end+1)=b;%#ok<AGROW>
        else
            srcB(end+1)=b;
        end
    end
end

function dstB=findVirtualInportBlockForPort(inP)


    import slslicer.internal.*
    dstB=[];
    for i=1:length(inP)
        p=inP(i);
        if(p>0)

            b=get(p,'ParentHandle');
            if strcmp(get(b,'BlockType'),'SubSystem')&&...
                ~strcmp(get(b,'MaskType'),'Sigbuilder block')&&...
                strcmp(get(b,'SFBlockType'),'NONE')
                sysO=get(b,'Object');

                if strcmp(get(p,'PortType'),'inport')
                    if isempty(sysO.getChildren)
                        dstB(end+1)=b;
                    else
                        ipBlk=SLGraphUtil.getInportBlock(sysO,get(p,'PortNumber'));
                        if~isempty(ipBlk)
                            if strcmp(sysO.Variant,'on')
                                sysO=get_param(sysO.ActiveVariantBlock,'Object');
                                ipBlkName=ipBlk.Name;
                                ipBlk=SLGraphUtil.getInportBlockByName(sysO,ipBlkName);
                            end
                            if~isempty(ipBlk)
                                for j=1:length(ipBlk)
                                    dstB(end+1)=ipBlk(j).handle;
                                end
                            end
                        end
                    end
                elseif strcmp(get(p,'PortType'),'enable')

                    dstB(end+1)=b;
                elseif strcmp(get(p,'PortType'),'trigger')
                    dstB(end+1)=b;
                elseif strcmp(get(p,'PortType'),'ifaction')
                    dstB(end+1)=b;
                end

            elseif strcmp(get(b,'BlockType'),'ModelReference')

                dstB(end+1)=b;
            elseif strcmp(get(b,'BlockType'),'Inport')
                dstB(end+1)=b;
            else
                dstB(end+1)=b;
            end
        end
    end
end

function outP=findDstPortsForOutport(p)
    l=get(p,'Line');
    if l>0
        outP=get(l,'DstPortHandle');
        if outP<0
            outP=[];
        end
    else
        outP=[];
    end
end





