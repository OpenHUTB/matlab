classdef RunnableBuilder<handle




    properties(Access=protected)
        M3iRunnable;
        ChangeLogger;
        AddedBlocks;
    end

    methods(Abstract)
        [runnablePath,subsystemPath]=create(this,parentSystem);
        subsystemPath=update(this,runnablePath,parentSystem);
    end

    methods
        function this=RunnableBuilder(m3iRunnable,changeLogger)
            this.M3iRunnable=m3iRunnable;
            this.ChangeLogger=changeLogger;
            this.AddedBlocks=[];
        end

        function blocks=getAddedBlocks(this)
            blocks=this.AddedBlocks;
        end
    end

    methods(Access=protected)
        function addedBlock(this,blockPath)
            this.AddedBlocks{end+1}=blockPath;
        end

        function blockPath=addOrGetBlock(this,blkType,blkName,parentSystem,paramValueArray)

            if nargin<5
                paramValueArray={};
            end

            blkHandle=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(...
            parentSystem,blkType,blkName);
            alreadyExists=~isempty(blkHandle);

            if alreadyExists
                blockPath=getfullname(blkHandle);
            else
                blockPath=this.addBlock(blkType,blkName,parentSystem,paramValueArray);
            end
        end

        function blockPath=addBlock(this,blkType,blkName,parentSystem,paramValueArray)

            processParamValueArray=nargin>4;

            blkHandle=add_block(['built-in/',blkType],...
            [parentSystem,'/',blkName],...
            'MakeNameUnique','on');
            blockPath=getfullname(blkHandle);

            if processParamValueArray
                for paramIdx=1:2:length(paramValueArray)
                    paramName=paramValueArray{paramIdx};
                    paramValue=paramValueArray{paramIdx+1};
                    if autosar.mm.mm2sl.RunnableBuilder.logSetParam(paramName)
                        autosar.mm.mm2sl.SLModelBuilder.set_param(...
                        this.ChangeLogger,blkHandle,paramName,paramValue);
                    else
                        set_param(blkHandle,paramName,paramValue);
                    end
                end
            end


            this.addedBlock(blockPath);


            this.ChangeLogger.logAddition('Automatic',[blkType,' block'],blockPath);
        end


        function[fcnCallInportBlkPath,alreadyExists]=addOrGetFcnCallInport(...
            this,fcnCallInportBlkPath,parentSystem)

            alreadyExists=~isempty(fcnCallInportBlkPath);
            if~alreadyExists
                fcnCallInportBlkPath=this.addOrGetBlock('Inport',this.M3iRunnable.Name,parentSystem);
            end
            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,fcnCallInportBlkPath,...
            'OutputFunctionCall','on');
            this.updateDescription(fcnCallInportBlkPath);
        end


        function subsystemPath=addOrGetFcnCallSubsystem(this,fcnCallInportBlkPath,name,parentSystem)
            dstPortHs=autosar.mm.mm2sl.SLModelBuilder.getAllDestinationPortsThroughVirtualBlocks(...
            fcnCallInportBlkPath);
            if isempty(dstPortHs)
                subsystemPath=this.addOrGetBlock('SubSystem',name,parentSystem,...
                {'Position',[200,500,400,700]});
            else
                subsystemPath=get_param(dstPortHs{1},'Parent');
            end
        end


        function triggerPortBlkPath=addOrGetTriggerPort(this,subsystemPath)
            ssFcnPorts=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(subsystemPath,...
            'TriggerPort','','TriggerType','function-call');
            if isempty(ssFcnPorts)
                triggerPortBlkPath=this.addOrGetBlock('TriggerPort','function',subsystemPath);
            else
                triggerPortBlkPath=ssFcnPorts(1);
            end

            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
            triggerPortBlkPath,...
            'TriggerType','function-call',...
            'StatesWhenEnabling','held');
        end

        function updateDescription(this,blockPath)
            m3iRun=this.M3iRunnable;


            slDesc=autosar.mm.util.DescriptionHelper.getSLDescFromM3IDesc(m3iRun.desc);
            if~isempty(slDesc)
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blockPath,...
                'Description',slDesc);
            end
        end
    end

    methods(Static,Access=protected)
        function path=removeSystemName(systemName,path)
            path=regexprep(path,['^',systemName,'/'],'');
        end
    end

    methods(Static,Access=private)
        function logIt=logSetParam(paramName)
            logIt=~any(strcmp(paramName,{'Position','ShowName','TaskPriority'}));
        end
    end

    methods(Static)
        function blockPath=findBlockWithType(blocks,blockType)
            blockPath='';
            if~isempty(blocks)
                foundBlocks=blocks(cellfun(@(blk)strcmp(get_param(blk,'BlockType'),...
                blockType),blocks));
                if~isempty(foundBlocks)
                    blockPath=foundBlocks{1};
                end
            end
        end
    end
end
