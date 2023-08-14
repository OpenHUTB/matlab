classdef WrapSubsystemCreater<handle




    properties
blocks
    end
    methods(Access=public)
        function this=WrapSubsystemCreater(blocks)
            this.blocks=blocks;
        end

        function parents=create(this)
            parents=arrayfun(@(aBlock)this.createOne(aBlock),this.blocks);
        end
    end
    methods(Access=private)
        function parent=createOne(this,subsys)
            pos=get_param(subsys,'Position');

            blockHandle=this.getSubsysOrMdlBlkHandleFromSubsys(subsys);

            ssObj=get_param(bdroot(subsys(1)),'Object');
            ssObj.localCreateSubSystem(subsys);

            parent=get_param(get_param(subsys,'Parent'),'Handle');
            set_param(parent,'Name',get_param(subsys,'Name'));
            set_param(parent,'Position',pos);


            this.updateParentSubsystemPortNames(parent,blockHandle,'Inport');
            this.updateParentSubsystemPortNames(parent,blockHandle,'Outport');
        end

        function blockHandle=getSubsysOrMdlBlkHandleFromSubsys(~,subsys)
            aBlk=subsys(1);
            ssType=Simulink.SubsystemType(aBlk);
            if(ssType.isSubsystem)
                blockHandle=aBlk;
            elseif(ssType.isModelBlock(aBlk))
                modelName=get_param(aBlk,'ModelName');
                if~bdIsLoaded(modelName)
                    load_system(modelName);
                end
                blockHandle=get_param(modelName,'Handle');
            else
                assert(false,'Unsupported block type %s',ssType.getType);
            end
        end

        function updateParentSubsystemPortNames(this,parent,currentBlock,blockType)


            assert(strcmp(blockType,'Inport')||strcmp(blockType,'Outport'),'Unsupported port block type');
            findOptions={'SearchDepth',1,'LookUnderMasks','on','FollowLinks','on',...
            'MatchFilter',@Simulink.match.allVariants};

            portBlocks=find_system(currentBlock,findOptions{:},'BlockType',blockType);
            portBlocksInParent=find_system(parent,findOptions{:},'BlockType',blockType);
            this.randomizePortNames(portBlocksInParent);
            for idx=1:numel(portBlocks)
                if slfeature('RightClickBuild')
                    if Simulink.ModelReference.Conversion.isBusElementPort(portBlocks(idx))
                        portName=get_param(portBlocks(idx),'PortName');
                    else
                        portName=get_param(portBlocks(idx),'Name');
                    end
                else
                    portName=get_param(portBlocks(idx),'Name');
                end
                portIdx=str2double(get_param(portBlocks(idx),'Port'));
                set_param(portBlocksInParent(portIdx),'Name',portName);
            end
        end

        function randomizePortNames(~,ports)
            N=numel(ports);
            for idx=1:N
                set_param(ports(idx),'Name',Simulink.ModelReference.Conversion.Utilities.getARandomName());
            end
        end
    end
end
