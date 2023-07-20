classdef(Hidden,Sealed)Connector<autosar.arch.ArchElement&matlab.mixin.CustomDisplay




    properties(Dependent=true,SetAccess=private)
        SourcePort;
        DestinationPort;
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(~)

            proplist={'Name','SimulinkHandle','Parent','SourcePort',...
            'DestinationPort'};
            propgrp=matlab.mixin.util.PropertyGroup(proplist);
        end
    end

    methods(Hidden,Static)
        function this=create(lineH)

            this=autosar.arch.Connector(lineH);
        end
    end

    methods(Hidden,Access=private)
        function this=Connector(lineH)




            lineH=get_param(lineH,'Handle');
            assert(autosar.arch.Utils.isLine(lineH)&&...
            autosar.arch.Connector.isLineValidConnector(lineH),...
            'not a valid line  is passed to Connector');


            this@autosar.arch.ArchElement(lineH);
        end
    end

    methods
        function port=get.SourcePort(this)

            this.checkValidSimulinkHandle();

            srcPortH=get_param(this.SimulinkHandle,'SrcPortHandle');
            port=autosar.arch.PortBase.createPort(srcPortH);
        end

        function port=get.DestinationPort(this)

            this.checkValidSimulinkHandle();

            dstPortH=get_param(this.SimulinkHandle,'DstPortHandle');
            port=autosar.arch.PortBase.createPort(dstPortH);
        end
    end

    methods(Hidden,Access=protected)

        function name=getName(this)

            this.checkValidSimulinkHandle();


            if isa(this.SourcePort,'autosar.arch.CompPort')
                name=[this.SourcePort.Parent.Name,'_',this.SourcePort.Name];
            else
                name=this.SourcePort.Name;
            end

            name=[name,'_'];

            if isa(this.DestinationPort,'autosar.arch.CompPort')
                name=[name,this.DestinationPort.Parent.Name,'_',this.DestinationPort.Name];
            else
                name=[name,this.DestinationPort.Name];
            end

            maxShortNameLength=get_param(this.getRootArchModelH(),'AutosarMaxShortNameLength');
            name=arxml.arxml_private('p_create_aridentifier',name,maxShortNameLength);
        end

        function setName(this,~)
            DAStudio.error('autosarstandard:api:CannotSetNameForConnector',...
            getfullname(this.SimulinkHandle));
        end

        function destroyImpl(this)

            this.checkValidSimulinkHandle();

            delete_line(this.SimulinkHandle);
            delete(this);
        end

        function parentObj=getParent(this)

            this.checkValidSimulinkHandle();

            if isa(this.SourcePort,'autosar.arch.ArchPort')
                parentObj=this.SourcePort.Parent;
            else
                parentObj=this.SourcePort.Parent.Parent;
            end
        end
    end

    methods(Hidden,Static)
        function tf=isLineValidConnector(lineH)

            tf=get_param(lineH,'SrcPortHandle')~=-1&&...
            get_param(lineH,'SrcBlockHandle')~=-1&&...
            get_param(lineH,'DstPortHandle')~=-1&&...
            get_param(lineH,'DstBlockHandle')~=-1;
        end

        function connObj=connect(compositionObj,srcObj,dstObj)



            connObj=autosar.arch.Connector.empty();


            autosar.arch.Connector.checkIfConnectionIsValid(...
            compositionObj,srcObj,dstObj);





            SimulinkListenerAPI.clearUndoRedoARPropsCache();

            if((isa(srcObj,'autosar.arch.CompPort')&&...
                isa(dstObj,'autosar.arch.CompPort'))||...
                (isa(srcObj,'autosar.arch.CompPort')&&...
                isa(dstObj,'autosar.arch.ArchPort'))||...
                (isa(srcObj,'autosar.arch.ArchPort')&&...
                isa(dstObj,'autosar.arch.CompPort')))




                [srcObj,dstObj]=autosar.arch.Connector.determineSrcAndDstPortsForAddLine(...
                srcObj,dstObj);


                addedLine=autosar.arch.Connector.connectPairOfPorts(compositionObj,srcObj,dstObj);

                if~isempty(addedLine)
                    connObj=autosar.arch.Connector.create(addedLine);
                end

            elseif((isa(srcObj,'autosar.arch.Component')||...
                isa(srcObj,'autosar.arch.Composition'))&&...
                (isa(dstObj,'autosar.arch.Component')||...
                isa(dstObj,'autosar.arch.Composition')))


                addedLines=autosar.arch.Connector.autoConnectSrcToDst(...
                compositionObj,srcObj,dstObj);
                if~isempty(addedLines)
                    connObj=arrayfun(@(x)autosar.arch.Connector.create(x),addedLines);
                end

            elseif(isempty(srcObj)&&...
                (isa(dstObj,'autosar.arch.Composition')||...
                isa(dstObj,'autosar.arch.Component')))||...
                (isempty(dstObj)&&...
                (isa(srcObj,'autosar.arch.Composition')||...
                isa(srcObj,'autosar.arch.Component')))


                addedLines=autosar.arch.Connector.autoConnectSrcToDst(...
                compositionObj,srcObj,dstObj);
                if~isempty(addedLines)
                    connObj=arrayfun(@(x)autosar.arch.Connector.create(x),addedLines);
                end

            else

                if isempty(srcObj)
                    srcName='root';
                else
                    srcName=getfullname(srcObj.SimulinkHandle);
                end

                if isempty(dstObj)
                    dstName='root';
                else
                    dstName=getfullname(dstObj.SimulinkHandle);
                end
                DAStudio.error('autosarstandard:api:SrcAndDstNotSupportedForConnectivityInArchModel',...
                srcName,dstName);
            end
        end
    end

    methods(Static,Access=private)

        function checkIfConnectionIsValid(compositionObj,srcObj,dstObj)




            assert(isempty(srcObj)||isa(srcObj,'autosar.arch.PortBase')||...
            isa(srcObj,'autosar.arch.ComponentBase'),'srcObj not expected type');
            assert(isempty(dstObj)||isa(dstObj,'autosar.arch.PortBase')||...
            isa(dstObj,'autosar.arch.ComponentBase'),'dstObj not expected type');


            if isempty(srcObj)&&isempty(dstObj)
                DAStudio.error('autosarstandard:api:SrcAndDstNotSupportedForConnectivityInArchModel',...
                'root','root');
            end


            if isempty(srcObj)&&(~autosar.arch.Utils.isSubSystem(dstObj.SimulinkHandle)&&...
                ~autosar.arch.Utils.isModelBlock(dstObj.SimulinkHandle))
                DAStudio.error('autosarstandard:api:SrcAndDstNotSupportedForConnectivityInArchModel',...
                'root','root');
            end


            if isempty(dstObj)&&(~autosar.arch.Utils.isSubSystem(srcObj.SimulinkHandle)&&...
                ~autosar.arch.Utils.isModelBlock(srcObj.SimulinkHandle))
                DAStudio.error('autosarstandard:api:SrcAndDstNotSupportedForConnectivityInArchModel',...
                'root','root');
            end


            if isa(srcObj,'autosar.arch.Model')&&isa(dstObj,'autosar.arch.Model')
                DAStudio.error('autosarstandard:api:SrcAndDstNotSupportedForConnectivityInArchModel',...
                getfullname(srcObj.SimulinkHandle),getfullname(dstObj.SimulinkHandle));
            end

            isSrcArchPort=isempty(srcObj)||isa(srcObj,'autosar.arch.ArchPort');
            isDstArchPort=isempty(dstObj)||isa(dstObj,'autosar.arch.ArchPort');


            if((isSrcArchPort&&isDstArchPort)&&...
                ((autosar.arch.Utils.isBusInPortBlock(srcObj.SimulinkHandle)&&...
                autosar.arch.Utils.isBusOutPortBlock(dstObj.SimulinkHandle))||...
                (autosar.arch.Utils.isBusOutPortBlock(srcObj.SimulinkHandle)&&...
                autosar.arch.Utils.isBusInPortBlock(dstObj.SimulinkHandle))))
                DAStudio.error('autosarstandard:api:PassThroughConnectorsAreNotSupportedInArchModel',...
                getfullname(srcObj.SimulinkHandle),getfullname(srcObj.SimulinkHandle));
            end


            if isa(srcObj,'autosar.arch.CompPort')&&...
                isa(dstObj,'autosar.arch.CompPort')&&...
                (srcObj.Parent.SimulinkHandle==dstObj.Parent.SimulinkHandle)
                DAStudio.error('autosarstandard:api:SelfConnectionsAreNotSupportedInArchModel',...
                getfullname(srcObj.SimulinkHandle),getfullname(srcObj.SimulinkHandle));
            end



            if((~isempty(srcObj)&&~isempty(dstObj))&&...
                ((srcObj.Parent.SimulinkHandle==dstObj.Parent.SimulinkHandle)&&...
                ((autosar.arch.Utils.isBusInPortBlock(srcObj.SimulinkHandle)&&...
                autosar.arch.Utils.isBusInPortBlock(dstObj.SimulinkHandle))||...
                (autosar.arch.Utils.isBusOutPortBlock(srcObj.SimulinkHandle)&&...
                autosar.arch.Utils.isBusOutPortBlock(dstObj.SimulinkHandle)))))
                DAStudio.error('autosarstandard:api:SelfConnectionsAreNotSupportedInArchModel',...
                getfullname(srcObj.SimulinkHandle),getfullname(srcObj.SimulinkHandle));
            end



            srcObjParent=autosar.arch.Connector.getConnectorOwner(compositionObj,srcObj,dstObj);
            dstObjParent=autosar.arch.Connector.getConnectorOwner(compositionObj,dstObj,srcObj);

            if isempty(srcObj)
                srcSlHandle=srcObjParent.SimulinkHandle;
            else
                srcSlHandle=srcObj.SimulinkHandle;
            end


            if isempty(dstObj)
                dstSlHandle=dstObjParent.SimulinkHandle;
            else
                dstSlHandle=dstObj.SimulinkHandle;
            end

            if(srcObjParent.SimulinkHandle~=dstObjParent.SimulinkHandle)
                DAStudio.error('autosarstandard:api:CannotConnectSrcAndDstPortsNotInSameComposition',...
                getfullname(srcSlHandle),getfullname(dstSlHandle));
            end



            if(compositionObj.SimulinkHandle~=srcObjParent.SimulinkHandle)||...
                (compositionObj.SimulinkHandle~=dstObjParent.SimulinkHandle)
                DAStudio.error('autosarstandard:api:CannotConnectSrcAndDstPortsNotOwnedByParentComposition',...
                getfullname(srcSlHandle),getfullname(dstSlHandle),...
                getfullname(compositionObj.SimulinkHandle));
            end
        end

        function[srcObjReal,dstObjReal]=determineSrcAndDstPortsForAddLine(srcObj,dstObj)






            if((autosar.arch.Utils.isInPort(srcObj.SimulinkHandle)&&...
                autosar.arch.Utils.isBusInPortBlock(dstObj.SimulinkHandle))||...
...
                (autosar.arch.Utils.isBusOutPortBlock(srcObj.SimulinkHandle)&&...
                autosar.arch.Utils.isOutPort(dstObj.SimulinkHandle))||...
...
                (autosar.arch.Utils.isInPort(srcObj.SimulinkHandle)&&...
                autosar.arch.Utils.isOutPort(dstObj.SimulinkHandle))...
                )
                srcObjReal=dstObj;
                dstObjReal=srcObj;
            else
                srcObjReal=srcObj;
                dstObjReal=dstObj;
            end
        end

        function addedLines=autoConnectSrcToDst(compositionObj,srcObj,dstObj)








            assert(isempty(srcObj)||isa(srcObj,'autosar.arch.PortBase')||...
            isa(srcObj,'autosar.arch.ComponentBase'),'srcObj not expected type');
            assert(isempty(dstObj)||isa(dstObj,'autosar.arch.ArchElement')||...
            isa(srcOdstObjbj,'autosar.arch.ComponentBase'),'dstObj not expected type');


            if isempty(srcObj)
                assert(~isempty(dstObj),'srcObj and dstObj cannot be both empty.');
                srcObjParent=autosar.arch.Connector.getConnectorOwner(compositionObj,srcObj,dstObj);
                [portHdls1,portNames1]=...
                autosar.arch.Connector.getInportHdlsForRootModel(srcObjParent.SimulinkHandle);
            else
                assert(autosar.arch.Utils.isSubSystem(srcObj.SimulinkHandle)||...
                autosar.arch.Utils.isModelBlock(srcObj.SimulinkHandle),'expected a comp block');
                [portHdls1,portNames1,]=...
                autosar.arch.Connector.getOutportHdlsForComp(srcObj.SimulinkHandle);
            end

            if isempty(dstObj)
                assert(~isempty(srcObj),'srcObj and dstObj cannot be both empty.');
                dstObjParent=autosar.arch.Connector.getConnectorOwner(compositionObj,dstObj,srcObj);
                [portHdls2,portNames2]=...
                autosar.arch.Connector.getOutportHdlsForRootModel(dstObjParent.SimulinkHandle);
            else
                assert(autosar.arch.Utils.isSubSystem(dstObj.SimulinkHandle)||...
                autosar.arch.Utils.isModelBlock(dstObj.SimulinkHandle),'expected a comp block');
                [portHdls2,portNames2]=...
                autosar.arch.Connector.getInportHdlsForComp(dstObj.SimulinkHandle);
            end


            addedLines=autosar.arch.Connector.connectPortsBasedOnNameMatching(...
            compositionObj,...
            portHdls1,portHdls2,...
            portNames1,portNames2);
        end

        function[outportHdls,outportNames]=getOutportHdlsForComp(slHandle)
            isInput=false;
            [outportHdls,outportNames]=autosar.arch.Connector.getPortHdlsForComp(...
            slHandle,isInput);
        end

        function[inportHdls,inportNames]=getInportHdlsForComp(slHandle)
            isInput=true;
            [inportHdls,inportNames]=autosar.arch.Connector.getPortHdlsForComp(...
            slHandle,isInput);
        end

        function[portHdls,portNames]=getPortHdlsForComp(slHandle,isInput)
            ph=get_param(slHandle,'PortHandles');

            if isInput
                tmpPortHdls=autosar.arch.Utils.getSLInportHandles(slHandle);
            else
                tmpPortHdls=ph.Outport;
            end

            if autosar.arch.Utils.isSubSystem(slHandle)
                portHdls=tmpPortHdls;
            else
                portHdls=[];
                assert(autosar.arch.Utils.isModelBlock(slHandle),'expected a Model block');

                for i=1:length(tmpPortHdls)
                    portHdl=tmpPortHdls(i);
                    portBlocks=autosar.arch.Utils.findSLPortBlock(portHdl);
                    if(length(portBlocks)==1)&&...
                        ~autosar.arch.Utils.isBusPortBlock(portBlocks{1})

                        continue;
                    else
                        portHdls=[portHdls,portHdl];%#ok<AGROW>
                    end
                end
            end
            portObjs=arrayfun(@(x)autosar.arch.CompPort.create(x),portHdls);
            portNames=arrayfun(@(x)x.Name,portObjs,'UniformOutput',false);
        end

        function[outportHdls,outportNames]=getOutportHdlsForRootModel(rootModelH)
            srcPortBlkHdls=autosar.composition.Utils.findCompositeOutports(rootModelH);
            portObjs=arrayfun(@(x)autosar.arch.ArchPort.create(x),srcPortBlkHdls);
            outportNames=arrayfun(@(x)x.Name,portObjs,'UniformOutput',false);
            outportHdls=arrayfun(@(x)x.getPortH(),portObjs);
        end

        function[inportHdls,inportNames]=getInportHdlsForRootModel(rootModelH)
            dstPortBlkHdls=autosar.composition.Utils.findCompositeInports(rootModelH);
            portObjs=arrayfun(@(x)autosar.arch.ArchPort.create(x),dstPortBlkHdls);
            inportNames=arrayfun(@(x)x.Name,portObjs,'UniformOutput',false);
            inportHdls=arrayfun(@(x)x.getPortH(),portObjs);
        end

        function addedLine=connectPairOfPorts(compositionObj,srcPort,dstPort)



            addedLine=[];

            assert(isa(srcPort,'autosar.arch.PortBase')||...
            autosar.arch.Utils.isPort(srcPort),'Unexpected srcPort type');
            assert(isa(dstPort,'autosar.arch.PortBase')||...
            autosar.arch.Utils.isPort(dstPort),'Unexpected dstPort type');


            srcPortH=autosar.arch.Connector.resolvePortHandle(compositionObj,srcPort);
            dstPortH=autosar.arch.Connector.resolvePortHandle(compositionObj,dstPort);


            if(get_param(dstPortH,'Line')~=-1)
                return;
            end


            srcPortOwner=get_param(srcPortH,'Parent');
            if autosar.arch.Utils.isBusPortBlock(srcPortOwner)
                src=[get_param(srcPortOwner,'Name'),'/1'];
            else
                src=[get_param(srcPortOwner,'Name'),'/',num2str(get_param(srcPortH,'PortNumber'))];
            end

            dstPortOwner=get_param(dstPortH,'Parent');
            if autosar.arch.Utils.isBusPortBlock(dstPortOwner)
                dst=[get_param(dstPortOwner,'Name'),'/1'];
            else
                dst=[get_param(dstPortOwner,'Name'),'/',num2str(get_param(dstPortH,'PortNumber'))];
            end
            sys=getfullname(compositionObj.SimulinkHandle);
            try
                addedLine=add_line(sys,src,dst,'autorouting','smart');
            catch ME
                autosar.arch.Connector.throwPortConnectionError(srcPort,dstPort,ME);
            end
        end

        function portH=resolvePortHandle(compositionObj,portObj)
            if isa(portObj,'autosar.arch.PortBase')




                if isa(portObj,'autosar.arch.CompPort')&&(portObj.Parent==compositionObj)
                    portObj=portObj.getArchPort();
                end
                portH=portObj.getPortH();
            else
                assert(is_simulink_handle(portObj),'assume port object or handle passed in.')
                portH=portObj;
            end
        end

        function throwPortConnectionError(srcPort,dstPort,MECause)
            if~isa(srcPort,'autosar.arch.PortBase')||~isa(dstPort,'autosar.arch.PortBase')




                MECause.rethrow();
            end

            if isa(srcPort,'autosar.arch.ArchPort')
                srcType=DAStudio.message('autosarstandard:importer:Composition');
            else
                srcType=DAStudio.message('autosarstandard:importer:Component');
            end

            if isa(dstPort,'autosar.arch.ArchPort')
                dstType=DAStudio.message('autosarstandard:importer:Composition');
            else
                dstType=DAStudio.message('autosarstandard:importer:Component');
            end

            E=MSLException([srcPort.SimulinkHandle,dstPort.SimulinkHandle],...
            'autosarstandard:importer:FailedPortConnection',...
            DAStudio.message('autosarstandard:importer:FailedPortConnection',...
            srcPort.Name,...
            srcType,...
            srcPort.Parent.Name,...
            dstPort.Name,...
            dstType,...
            dstPort.Parent.Name)).addCause(MECause);
            E.throw();
        end

        function addedLines=connectPortsBasedOnNameMatching(...
            compositionObj,...
            portHdls1,portHdls2,...
            portNames1,portNames2)


            addedLines=[];

            if~iscell(portNames1)
                portNames1={portNames1};
            end
            if~iscell(portNames2)
                portNames2={portNames2};
            end

            for i=1:length(portNames1)
                idx=find(strcmp(portNames2,portNames1{i}));
                if~isempty(idx)

                    addedLine=autosar.arch.Connector.connectPairOfPorts(...
                    compositionObj,...
                    portHdls1(i),portHdls2(idx));
                    addedLines=[addedLines;addedLine];%#ok<AGROW>
                end
            end


            autosar.mm.mm2sl.layout.LayoutHelper.autoRouteLines(addedLines);
        end

        function connOwner=getConnectorOwner(compositionObj,archObj1,archObj2)
            if isa(archObj1,'autosar.arch.ComponentBase')
                connOwner=archObj1.Parent;
            elseif isa(archObj2,'autosar.arch.ComponentBase')
                connOwner=archObj2.Parent;
            else
                connOwner=compositionObj;
            end
        end
    end
end


