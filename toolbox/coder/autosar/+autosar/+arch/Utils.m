classdef(Hidden)Utils<handle




    methods(Static)

        function archElement=getArchElementForSlHandle(sysH)



            import autosar.arch.Utils;

            if Utils.isBlockDiagram(sysH)||autosar.composition.Utils.isCompositionBlock(sysH)
                archElement=autosar.arch.Composition.create(sysH);
            elseif Utils.isPort(sysH)
                archElement=autosar.arch.CompPort.create(sysH);
            elseif Utils.isBusPortBlock(sysH)
                archElement=autosar.arch.ArchPort.create(sysH);
            elseif Utils.isLine(sysH)
                archElement=autosar.arch.Connector.create(sysH);
            elseif Utils.isBlock(sysH)
                if autosar.bsw.ServiceComponent.isBswServiceComponent(sysH)

                    archElement=[];
                elseif autosar.composition.Utils.isComponentBlock(sysH)
                    archElement=autosar.arch.Component.create(sysH);
                else
                    assert(false,'Did not expect to get here');
                end
            else
                assert(false,'Did not expect to get here');
            end
        end

        function tf=isBlockDiagram(sysH)
            tf=strcmp(get_param(sysH,'Type'),'block_diagram');
        end

        function tf=isBlock(sysH)
            tf=strcmp(get_param(sysH,'Type'),'block');
        end

        function tf=isLine(sysH)
            tf=strcmp(get_param(sysH,'Type'),'line');
        end

        function tf=isSubSystem(sysH)
            tf=autosar.arch.Utils.isBlock(sysH)&&...
            strcmp(get_param(sysH,'BlockType'),'SubSystem');
        end

        function[tf,refModelName]=isModelBlock(sysH)
            refModelName='';
            tf=autosar.arch.Utils.isBlock(sysH)&&...
            strcmp(get_param(sysH,'BlockType'),'ModelReference');
            if(tf)
                refModelName=get_param(sysH,'ModelName');
            end
        end

        function tf=isPort(sysH)
            tf=strcmp(get_param(sysH,'Type'),'port');
        end

        function tf=isInPort(sysH)
            tf=autosar.arch.Utils.isPort(sysH)&&...
            strcmp(get_param(sysH,'PortType'),'inport');
        end

        function tf=isOutPort(sysH)
            tf=autosar.arch.Utils.isPort(sysH)&&...
            strcmp(get_param(sysH,'PortType'),'outport');
        end

        function tf=isBusInPortBlock(sysH)
            tf=autosar.arch.Utils.isBlock(sysH)&&...
            strcmp(get_param(sysH,'BlockType'),'Inport')&&...
            strcmp(get_param(sysH,'IsBusElementPort'),'on');
        end

        function tf=isBusOutPortBlock(sysH)
            tf=autosar.arch.Utils.isBlock(sysH)&&...
            strcmp(get_param(sysH,'BlockType'),'Outport')&&...
            strcmp(get_param(sysH,'IsBusElementPort'),'on');
        end

        function tf=isBusPortBlock(sysH)
            tf=autosar.arch.Utils.isBlock(sysH)&&...
            any(strcmp(get_param(sysH,'BlockType'),{'Inport','Outport'}))&&...
            strcmp(get_param(sysH,'IsBusElementPort'),'on');
        end

        function refModelName=ensureRefModelLoaded(modelBlkH)
            assert(autosar.arch.Utils.isModelBlock(modelBlkH),...
            '%s is not a model block handle',getfullname(modelBlkH));
            refModelName=get_param(modelBlkH,'ModelName');
            if~bdIsLoaded(refModelName)
                load_system(refModelName);
            end
        end

        function mdlBlkHs=findAllModelBlksReferencingModel(rootModelH,refModelName)
            rootModelH=get_param(rootModelH,'Handle');


            allMdlBlkHs=find_system(rootModelH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','ModelReference');
            mdlBlkHs=allMdlBlkHs(arrayfun(@(x)strcmp(...
            get_param(x,'ModelName'),refModelName),allMdlBlkHs));
        end

        function refreshModelBlocksReferencingModel(rootModelH,refModelName)
            mdlBlkHs=autosar.arch.Utils.findAllModelBlksReferencingModel(...
            rootModelH,refModelName);
            arrayfun(@(x)Simulink.ModelReference.refresh(x),mdlBlkHs);
        end

        function slPortBlks=findSLPortBlock(portH)

            assert(autosar.arch.Utils.isPort(portH),'unexpected portH input.');
            portType=get_param(portH,'PortType');
            portType(1)=upper(portType(1));
            portNum=get_param(portH,'PortNumber');
            slPortBlks=autosar.composition.sl2mm.ConnectorBuilder.findSLPortBlockFromPortNum(...
            portH,portType,portNum);
        end

        function slInportHandles=getSLInportHandles(blkH)
            ph=get_param(blkH,'PortHandles');
            slInportHandles=[];
            for i=1:length(ph.Inport)
                if strcmp(get_param(ph.Inport(i),'IsHidden'),'off')
                    slInportHandles=[slInportHandles,ph.Inport(i)];%#ok
                end
            end

        end
    end
end


