classdef Utils<handle



    properties(Constant,Access=private)
        InportLib='simulink/Sources/In1';
        OutportLib='simulink/Sinks/Out1';
        InBusElementLib='simulink/Ports & Subsystems/In Bus Element';
        OutBusElementLib='simulink/Ports & Subsystems/Out Bus Element';
    end

    methods(Static)






        function setParam(bepBlk,forRootNode,varargin)
            assert(strcmp(get_param(bepBlk,'IsBusElementPort'),'on'),...
            'expected a BusElementPort block');
            assert(islogical(forRootNode),'forRootNode should be boolean');

            if~forRootNode
                containsVirtuality=any(strcmp(varargin(1:2:end),'Virtuality'));
                if~containsVirtuality
                    set_param(bepBlk,varargin{:});
                    return;
                else
                    assert(numel(varargin)<=2,'Virtuality cannot be set at the same time as other variables')
                end
            end


            bepTree=autosar.simulink.bep.Utils.getTreeNodeObjectForBEP(bepBlk);
            if forRootNode
                elemName='';
            else
                elemName=get_param(bepBlk,'Element');
            end
            node=Simulink.internal.CompositePorts.TreeNode.findNode(bepTree,elemName);
            numParams=length(varargin)/2;
            for ii=1:numParams
                param=varargin{ii*2-1};
                value=varargin{ii*2};
                switch(param)
                case 'OutDataTypeStr'
                    Simulink.internal.CompositePorts.TreeNode.setDataTypeCL(node,value);
                case 'PortDimensions'
                    Simulink.internal.CompositePorts.TreeNode.setDimsCL(node,value);
                case 'VarSizeSig'
                    bepValue=value;
                    if strcmpi(value,'Yes')
                        bepValue='VARIABLE';
                    elseif strcmpi(value,'No')
                        bepValue='FIXED';
                    elseif strcmpi(value,'Inherit')
                        bepValue='INHERIT';
                    end
                    Simulink.internal.CompositePorts.TreeNode.setDimsModeCL(node,bepValue);
                case 'SampleTime'
                    Simulink.internal.CompositePorts.TreeNode.setSampleTimeCL(node,value);
                case 'OutMin'
                    Simulink.internal.CompositePorts.TreeNode.setMinCL(node,value);
                case 'OutMax'
                    Simulink.internal.CompositePorts.TreeNode.setMaxCL(node,value);
                case 'Unit'
                    if strcmp(get_param(bepBlk,'Unit'),'inherit')&&strcmp(value,'inherit')


                        continue
                    end
                    Simulink.internal.CompositePorts.TreeNode.setUnitCL(node,value);
                case 'SignalType'
                    Simulink.internal.CompositePorts.TreeNode.setComplexityCL(node,upper(value));
                case 'Virtuality'
                    Simulink.internal.CompositePorts.TreeNode.setVirtualityCL(node,...
                    autosar.simulink.bep.Utils.getVirtualityEnum(value));
                case{'PortName','Element'}
                    set_param(bepBlk,param,value);
                case{'BusOutputAsStruct','SamplingMode','Description'}

                otherwise
                    assert(false,'Unsupported parameter for Bus Element Port: %s',param);
                end
            end
        end






        function value=getParam(bepBlk,forRootNode,param)
            assert(strcmp(get_param(bepBlk,'IsBusElementPort'),'on'),...
            'expected a BusElementPort block');
            assert(islogical(forRootNode),'forRootNode should be boolean');

            if~forRootNode&&~strcmp(param,'Virtuality')
                value=get_param(bepBlk,param);
                return;
            end


            bepTree=autosar.simulink.bep.Utils.getTreeNodeObjectForBEP(bepBlk);
            if forRootNode
                elemName='';
            else
                elemName=get_param(bepBlk,'Element');
            end
            node=Simulink.internal.CompositePorts.TreeNode.findNode(bepTree,elemName);
            switch(param)
            case 'OutDataTypeStr'
                value=Simulink.internal.CompositePorts.TreeNode.getDataType(node);
            case 'PortDimensions'
                value=Simulink.internal.CompositePorts.TreeNode.getDims(node);
            case 'VarSizeSig'
                value=Simulink.internal.CompositePorts.TreeNode.getDimsMode(node);
            case 'SampleTime'
                value=Simulink.internal.CompositePorts.TreeNode.getSampleTime(node);
            case 'OutMin'
                value=Simulink.internal.CompositePorts.TreeNode.getMin(node);
            case 'OutMax'
                value=Simulink.internal.CompositePorts.TreeNode.getMax(node);
            case 'Unit'
                value=Simulink.internal.CompositePorts.TreeNode.getUnit(node);
            case 'SignalType'
                value=Simulink.internal.CompositePorts.TreeNode.getComplexity(node);
            case 'Virtuality'
                value=autosar.simulink.bep.Utils.getVirtualityStr(...
                Simulink.internal.CompositePorts.TreeNode.getVirtuality(node));
            case{'PortName','Element'}
                value=get_param(bepBlk,param);
            case{'BusOutputAsStruct','SamplingMode','Description'}

            otherwise
                assert(false,'Unsupported parameter for Bus Element Port: %s',param);
            end
        end


        function isRootPort=isRootPort(bepBlk)
            assert(strcmp(get_param(bepBlk,'IsBusElementPort'),'on'),...
            'expected a BusElementPort block');

            elementName=get_param(bepBlk,'Element');


            isRootPort=isempty(elementName);
        end


        function elements=getElements(bepBlk)
            assert(strcmp(get_param(bepBlk,'IsBusElementPort'),'on'),...
            'expected a BusElementPort block');


            bepTree=autosar.simulink.bep.Utils.getTreeNodeObjectForBEP(bepBlk);
            allElements=Simulink.internal.CompositePorts.TreeNode.findLeavesOfTree(bepTree);

            splitElements=cellfun(@(x)strsplit(x,'.'),allElements,'UniformOutput',false);
            elements=unique(cellfun(@(x)x{1},splitElements,'UniformOutput',false));
        end



        function[isUsingBusObj,busObjName]=isBEPUsingBusObject(bepBlk)
            datatype=autosar.simulink.bep.Utils.getParam(bepBlk,true,'OutDataTypeStr');
            datatype=strrep(datatype,' ','');
            isUsingBusObj=startsWith(datatype,'Bus:');
            if isUsingBusObj
                busObjName=autosar.utils.StripPrefix(datatype);
            else
                busObjName='';
            end
        end


        function bepBlocksAtRoot=findBusElementPortsAtRoot(modelName)


            options=Simulink.FindOptions('SearchDepth',1);
            bepBlocksAtRoot=Simulink.findBlocks(modelName,'IsBusElementPort','on',...
            'IsClientServer','off',options);
        end

        function isModeBep=isBepModePort(modelName,blk)



            assert(autosar.composition.Utils.isCompositePortBlock(blk),'Expected bus port block');

            slMapping=autosar.api.getSimulinkMapping(modelName);

            blkName=get_param(blk,'Name');
            isInport=strcmp(get_param(blk,'BlockType'),'Inport');
            if~codermapping.internal.bep.isMappableBEP(blk)

                isModeBep=false;
                return;
            end
            if isInport
                [port,~,dataAccessMode]=slMapping.getInport(blkName);
            else
                [port,~,dataAccessMode]=slMapping.getOutport(blkName);
            end



            isModeBep=any(strcmp(dataAccessMode,{'ModeSend','ModeReceive'}));

            if~isModeBep


                arProps=autosar.api.getAUTOSARProperties(modelName);


                if isInport
                    isModeBep=~isempty(arProps.find([],'ModeReceiverPort','Name',port));
                else
                    isModeBep=~isempty(arProps.find([],'ModeSenderPort','Name',port));
                end


                componentAdapter=autosar.ui.wizard.builder.ComponentAdapter.getComponentAdapter(modelName);
                interfaceName=componentAdapter.getAutosarInterfaceName(blk);


                isModeBep=isModeBep||~isempty(arProps.find([],'ModeSwitchInterface','Name',interfaceName));
            end
        end

        function bep=addBusElement(modelName,portName,elementName,isInport,portNumber)
            if isInport
                bepLibPath=autosar.simulink.bep.Utils.InBusElementLib;
                bepBlkName='In Bus Element';
            else
                bepLibPath=autosar.simulink.bep.Utils.OutBusElementLib;
                bepBlkName='Out Bus Element';
            end



            existingBEPWithSamePortName=find_system(...
            modelName,'SearchDepth',1,'PortName',portName,...
            'IsBusElementPort','on');
            if isempty(existingBEPWithSamePortName)
                bep=add_block(bepLibPath,[modelName,'/',bepBlkName],...
                'MakeNameUnique','on','CreateNewPort','on',...
                'Port',portNumber,'PortName',portName,...
                'Element',elementName);
            else
                bep=add_block(existingBEPWithSamePortName{1},...
                existingBEPWithSamePortName{1},...
                'MakeNameUnique','on',...
                'Element',elementName);
            end
        end

        function blk=addPortBlock(modelName,portName,elementName,isInport,portNumber)
            if isInport
                libPath=autosar.simulink.bep.Utils.InportLib;
            else
                libPath=autosar.simulink.bep.Utils.OutportLib;
            end
            if isempty(elementName)


                blkName=portName;
            else
                blkName=[portName,'_',elementName];
            end

            blk=add_block(libPath,[modelName,'/',blkName],...
            'MakeNameUnique','on',...
            'Port',portNumber,...
            'Name',blkName);
        end

        function str=getBusPortBlockTypeStr(blk)

            assert(autosar.composition.Utils.isCompositePortBlock(blk),'Expected Bus Element Port block');
            if strcmp(get_param(blk,'BlockType'),'Inport')
                str=message('Simulink:BusElPorts:BlockNameBEI').getString();
            else
                str=message('Simulink:BusElPorts:BlockNameBEO').getString();
            end
        end
    end

    methods(Static,Access=private)
        function bepTree=getTreeNodeObjectForBEP(bepBlk)
            bepBlkH=get_param(bepBlk,'Handle');
            pb=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(bepBlkH);
            bepTree=pb.port.tree;
        end

        function vituality=getVirtualityStr(virtualityEnum)
            switch virtualityEnum
            case sl.mfzero.treeNode.Virtuality.INHERIT
                vituality='inherit';
            case sl.mfzero.treeNode.Virtuality.VIRTUAL
                vituality='virtual';
            case sl.mfzero.treeNode.Virtuality.NON_VIRTUAL
                vituality='nonvirtual';
            otherwise
                assert(false,'Unexpected result');
            end
        end

        function vituality=getVirtualityEnum(virtualityStr)
            switch virtualityStr
            case 'inherit'
                vituality=sl.mfzero.treeNode.Virtuality.INHERIT;
            case 'virtual'
                vituality=sl.mfzero.treeNode.Virtuality.VIRTUAL;
            case 'nonvirtual'
                vituality=sl.mfzero.treeNode.Virtuality.NON_VIRTUAL;
            otherwise
                assert(false,'Unexpected result');
            end
        end
    end
end


