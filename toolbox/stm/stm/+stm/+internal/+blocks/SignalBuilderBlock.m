classdef SignalBuilderBlock<stm.internal.blocks.SignalSourceBlock

    properties
        originalIdx;
        overrideScenario;
    end

    methods
        function obj=SignalBuilderBlock(modelname,overrideScenario)
            if nargin<=1,overrideScenario=[];end
            handle=find_system(modelname,...
            'SearchDepth',1,...
            'LoadFullyIfNeeded','off',...
            'FollowLinks','off',...
            'LookUnderMasks','all',...
            'BlockType','SubSystem',...
            'PreSaveFcn','sigbuilder_block(''preSave'');');
            if(iscell(handle)&&~isempty(handle))
                if~isscalar(handle)
                    obj.handle=[];
                else
                    obj.handle=handle{1};
                end
            else
                obj.handle=handle;
            end

            if isempty(overrideScenario)&&~isempty(obj.handle)
                [~,overrideScenario]=signalbuilder(obj.handle,'activegroup');
            end

            obj.overrideScenario=overrideScenario;
        end

        function handle=getHandle(obj)
            handle=obj.handle;
        end

        function groupNames=getComponentNames(obj)
            [~,~,~,groupNames]=signalbuilder(obj.handle);
        end

        function[handle,ind]=setActiveComponent(obj,groupName)

            [~,~,~,groupNames]=signalbuilder(obj.handle);


            groupNameIndex=find(strcmp(groupName,groupNames));
            if(isempty(groupNameIndex)&&~isempty(groupName))
                error(message('stm:general:GroupNotFound',groupName));
            end
            ind=signalbuilder(obj.handle,'ActiveGroup');
            obj.originalIdx=ind;
            signalbuilder(obj.handle,'ActiveGroup',groupNameIndex);
            handle=obj.handle;
        end

        function sig=getSignalFromComponent(obj,groupName,inputSignalFile)
            if(isempty(inputSignalFile))
                sig=stm.internal.util.getSignalFromSignalBuilderGroup(obj.handle,groupName,inputSignalFile);
            else
                stm.internal.util.getSignalFromSignalBuilderGroup(obj.handle,groupName,inputSignalFile);
            end
        end

        function tMax=getMaxTime(obj,groupName)
            tMax=stm.internal.util.getMaxTimeFromSignalBuilder(obj.handle,groupName);
        end

        function delete(obj,ind)
            if nargin==2
                signalbuilder(obj.handle,'ActiveGroup',ind);
            elseif~isempty(obj.originalIdx)
                signalbuilder(obj.handle,'ActiveGroup',obj.originalIdx);
            end
        end

        function type=getSignalBlockType(~)
            type='externalInputSignalGroup';
        end
    end
end
