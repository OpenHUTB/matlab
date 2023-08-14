classdef BEPInterfacePropagationUtils<handle




    properties(Constant,Access=private)
        DefaultInterface='Inherit: auto';
    end

    methods(Static)
        function propagateInterfacesFromConnections(blkH)



            import autosar.composition.studio.BEPInterfacePropagationUtils


            portHandles=get_param(blkH,'PortHandles');
            inportHandles=portHandles.Inport;
            outportHandles=portHandles.Outport;

            lineHandles=get_param(blkH,'LineHandles');
            inportLineHandles=lineHandles.Inport;
            outportLineHandles=lineHandles.Outport;

            assert(numel(inportHandles)==numel(inportLineHandles),'Expected equal numbers of ports and lines');
            assert(numel(outportHandles)==numel(outportLineHandles),'Expected equal numbers of ports and lines');





            for portIdx=1:length(inportHandles)

                BEPInterfacePropagationUtils.propagateInterfaceInfoForPort(...
                blkH,inportHandles(portIdx),inportLineHandles(portIdx),true);
            end

            for portIdx=1:length(outportHandles)

                BEPInterfacePropagationUtils.propagateInterfaceInfoForPort(...
                blkH,outportHandles(portIdx),outportLineHandles(portIdx),false);
            end
        end

        function populateInterfaceInformationInModel(compositionModel,modelName)


            import autosar.composition.studio.BEPInterfacePropagationUtils

            bdH=get_param(modelName,'Handle');


            compositePorts=find_system(bdH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'RegExp','on',...
            'BlockType','\<Inport\>|\<Outport\>','IsBusElementPort','on');
            portNames=get_param(compositePorts,'PortName');
            if iscell(portNames)&&numel(portNames)>1
                [~,Index]=unique(portNames,'stable');
                compositePorts=compositePorts(Index);
            end

            for ii=1:length(compositePorts)
                compositePort=compositePorts(ii);
                [isBus,busObjName]=autosar.simulink.bep.Utils.isBEPUsingBusObject(compositePort);
                if isBus
                    [varExists,busObj]=autosar.utils.Workspace.objectExistsInModelScope(...
                    compositionModel,busObjName);
                    assert(varExists,'Cannot find bus object with name: %s',busObjName);
                    if~isempty(busObj.Elements)
                        BEPInterfacePropagationUtils.addBusPortsForAllElementsInBusObject(...
                        bdH,busObj,compositePort);
                        continue;
                    else
                        elementName='';
                    end
                else

                    elementName='Value';
                end
                set_param(compositePort,'Element',elementName);
            end
        end
    end

    methods(Static,Access=private)
        function setBEPVirtuality(bepBlkH,busElementObj)


            assert(isa(busElementObj,'Simulink.BusElement'));
            if startsWith(busElementObj.DataType,'Bus:')
                autosar.simulink.bep.Utils.setParam(bepBlkH,false,'Virtuality','nonvirtual');
            end
        end

        function addBusPortsForAllElementsInBusObject(componentH,busObj,firstBusElementPort)





            import autosar.composition.studio.BEPInterfacePropagationUtils


            ddTxn=systemcomposer.internal.DragDropTransaction();

            busPortBlockType=get_param(firstBusElementPort,'BlockType');
            isInport=strcmp(busPortBlockType,'Inport');

            portName=get_param(firstBusElementPort,'PortName');
            componentMdlName=get_param(componentH,'Name');

            busElements=busObj.Elements;


            set_param(firstBusElementPort,'Element',busElements(1).Name);
            BEPInterfacePropagationUtils.setBEPVirtuality(firstBusElementPort,busElements(1));

            position=get_param(firstBusElementPort,'Position');

            Simulink.BlockDiagram.arrangeSystem(componentH,'FullLayout','true','Animation','false');

            existingBEPs=find_system(componentMdlName,...
            'SearchDepth',1,'BlockType',busPortBlockType,...
            'IsBusElementPort','on','PortName',portName);
            existingBEPElmNames=get_param(existingBEPs,'Element');
            for elementIdx=2:length(busElements)
                elmName=busElements(elementIdx).Name;
                blockAlreadyExists=any(strcmp(existingBEPElmNames,elmName));
                if blockAlreadyExists


                    continue
                end
                bep=autosar.simulink.bep.Utils.addBusElement(componentMdlName,...
                portName,elmName,isInport,[]);
                BEPInterfacePropagationUtils.setBEPVirtuality(bep,busElements(elementIdx));


                shift=50;
                position=position+[0,shift,0,shift];
                set_param(bep,'Position',position);
            end

            ddTxn.commit();
        end

        function propagateInterfaceInfoForPort(blkH,portHandle,lineHandle,isInport)

            import autosar.composition.studio.BEPInterfacePropagationUtils

            outDataTypeStr=BEPInterfacePropagationUtils.DefaultInterface;

            if isInport
                portType='Inport';
                connectedToPortType='Outport';
                lineConnectionProperty='SrcPortHandle';
            else
                portType='Outport';
                connectedToPortType='Inport';
                lineConnectionProperty='DstPortHandle';
            end

            compositePortH=BEPInterfacePropagationUtils.findCompositePort(...
            blkH,portHandle,portType);

            if~BEPInterfacePropagationUtils.isInterfaceInherited(compositePortH)

                return;
            end


            if lineHandle==-1

                return;
            end
            connectedPortH=get_param(lineHandle,lineConnectionProperty);

            connectedPortH=connectedPortH(connectedPortH~=-1);

            for connectionIdx=1:length(connectedPortH)
                outDataTypeStr=...
                BEPInterfacePropagationUtils.getTypeFromConnectedPort(...
                connectedPortH(connectionIdx),connectedToPortType);
                if~strcmp(outDataTypeStr,BEPInterfacePropagationUtils.DefaultInterface)

                    break;
                end
            end

            autosar.simulink.bep.Utils.setParam(...
            compositePortH,true,'OutDataTypeStr',outDataTypeStr);
        end

        function compositePortH=findCompositePort(blkH,portHandle,blockType)

            portNumber=get_param(portHandle,'PortNumber');
            compositePortH=find_system(blkH,'SearchDepth',1,'BlockType',blockType,'Port',num2str(portNumber));
            if length(compositePortH)>1


                portNames=get_param(compositePortH,'PortName');
                assert(length(unique(portNames))==1,'Expected to find 1 port');
                compositePortH=compositePortH(1);
            end
        end

        function ret=isInterfaceInherited(compositePort)
            outDataTypeStr=get_param(compositePort,'OutDataTypeStr');
            ret=strcmp(outDataTypeStr,...
            autosar.composition.studio.BEPInterfacePropagationUtils.DefaultInterface);
        end

        function outDataTypeStr=inferInterfaceFromSystemPort(systemH,portH,blockType)

            import autosar.composition.studio.BEPInterfacePropagationUtils

            compositePortH=BEPInterfacePropagationUtils.findCompositePort(...
            systemH,portH,blockType);
            outDataTypeStr=...
            BEPInterfacePropagationUtils.inferInterfaceFromCompositePort(...
            compositePortH);
        end

        function outDataTypeStr=inferInterfaceFromCompositePort(compositePortH)

            import autosar.composition.studio.BEPInterfacePropagationUtils


            outDataTypeStr=BEPInterfacePropagationUtils.DefaultInterface;
            [isBus,busObjName]=...
            autosar.simulink.bep.Utils.isBEPUsingBusObject(compositePortH);
            if isBus
                outDataTypeStr=['Bus: ',busObjName];
            end
        end

        function outDataTypeStr=getTypeFromConnectedPort(connectedPortH,connectedToPortType)

            import autosar.composition.studio.BEPInterfacePropagationUtils

            connectedPortParent=get_param(connectedPortH,'Parent');
            connectedPortParentH=get_param(connectedPortParent,'Handle');
            parentType=get_param(connectedPortParentH,'Type');
            if strcmp(parentType,'block')

                blockType=get_param(connectedPortParentH,'BlockType');
                if strcmp(blockType,'SubSystem')

                    outDataTypeStr=...
                    BEPInterfacePropagationUtils.inferInterfaceFromSystemPort(...
                    connectedPortParentH,connectedPortH,connectedToPortType);
                elseif strcmp(blockType,'ModelReference')

                    refModelName=get_param(connectedPortParentH,'ModelName');
                    if~bdIsLoaded(refModelName)
                        load_system(refModelName);
                    end
                    refModelH=get_param(refModelName,'Handle');
                    outDataTypeStr=...
                    BEPInterfacePropagationUtils.inferInterfaceFromSystemPort(...
                    refModelH,connectedPortH,connectedToPortType);
                elseif any(strcmp(blockType,{'Inport','Outport'}))

                    outDataTypeStr=...
                    BEPInterfacePropagationUtils.inferInterfaceFromCompositePort(...
                    connectedPortParentH);
                else
                    assert(false,'Unexpected connection');
                end
            else
                assert(false,'Unexpected parent');
            end
        end
    end
end


