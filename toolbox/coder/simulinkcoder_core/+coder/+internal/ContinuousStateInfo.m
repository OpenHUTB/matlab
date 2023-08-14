

classdef ContinuousStateInfo<handle
    properties
ModelName
Subsystem
HasContinuousState
        ContinuousBlocks={}
    end
    methods
        function obj=ContinuousStateInfo(system)
            [mdl,sys]=strtok(system,'/');
            if~isempty(sys)
                obj.ModelName=mdl;
                obj.Subsystem=system;
            else
                obj.ModelName=mdl;
                obj.Subsystem='';
            end
            obj.getContinuousState;
        end
        function out=isInvalidBlock(~,blockpath)
            out=false;
            try
                get_param(blockpath,'Handle');
            catch me
                out=strcmp(me.identifier,'Simulink:Commands:InvSimulinkObjectName');
            end
        end
        function out=getBlockPathIndices(~,currentBlock)
            toModelBlock=regexp(currentBlock,'[^~]\|','end','all');
            if isempty(toModelBlock)
                out=length(currentBlock);
            else
                out=toModelBlock-1;
                out=[out,length(currentBlock)];
            end
        end
        function out=getBlockPathToModelBlock(obj,currentBlock)




            bpathIdx=obj.getBlockPathIndices(currentBlock);
            for i=1:length(bpathIdx)

                shortenedBlock=strrep(currentBlock(1:bpathIdx(i)),'~~','~');
                shortenedBlock=strrep(shortenedBlock,'~|','|');


                if~obj.isInvalidBlock(shortenedBlock)
                    break;
                end
            end
            out=shortenedBlock;
        end
        function assignContinuousBlockPaths(obj,continuousBlocks)
            if isempty(obj.Subsystem)
                continuousBlocksInModel={};
                for blockCount=1:length(continuousBlocks)
                    currentBlock=continuousBlocks{blockCount};
                    continuousBlocksInModel{end+1}=obj.getBlockPathToModelBlock(currentBlock);%#ok<AGROW>
                end
                if~isempty(continuousBlocksInModel)
                    obj.ContinuousBlocks=unique(continuousBlocksInModel);
                end
            else
                continuousBlocksInSubsystem={};
                for blockCount=1:length(continuousBlocks)
                    currentBlock=continuousBlocks{blockCount};
                    currentBlk=obj.getBlockPathToModelBlock(currentBlock);
                    if coder.internal.isBlockInSS(obj.Subsystem,currentBlk)
                        continuousBlocksInSubsystem{end+1}=currentBlk;%#ok<AGROW>
                    end
                end
                if~isempty(continuousBlocksInSubsystem)
                    obj.ContinuousBlocks=unique(continuousBlocksInSubsystem);
                end
            end
            if~isempty(obj.ContinuousBlocks)
                obj.HasContinuousState=true;
            end
        end

        function getContinuousState(obj)
            obj.HasContinuousState=false;
            obj.ContinuousBlocks={};


            states=Simulink.BlockDiagram.getInitialState(obj.ModelName);
            if~isempty(states)
                signals=states.signals;
                continuousBlocks=unique({signals(ismember({signals.label},'CSTATE')).blockName});
                if~isempty(continuousBlocks)
                    obj.assignContinuousBlockPaths(continuousBlocks);
                end
            end
        end
    end
end


