classdef TaskHighlighter<handle




    properties
MappingData
HighlightedTasks
MixedStyleNumTasks
MixedTaskStyle
UIObj
    end

    events
HighlightingOnEvent
HighlightingOffEvent
    end

    properties(Constant)

        ThreadColours=[...
        5,108,201;...
        119,72,48;...
        162,20,47;...
        0,110,131;...
        251,231,188;...
        152,253,123;...
        255,112,253;...
        217,83,25;...
        0,210,221;...
        126,47,142]...
        /255;
        IRTColors=[...
        97,189,252;...
        32,178,170;...
        138,43,226]...
        /255;
        ColorStr=[char(9600),char(9600),char(9600),char(9600)];
    end

    methods
        function obj=TaskHighlighter(uiObj)
            obj.UIObj=uiObj;
            obj.HighlightedTasks=containers.Map('KeyType','double','ValueType','any');
            obj.MixedStyleNumTasks=containers.Map('KeyType','double','ValueType','any');
            obj.MixedTaskStyle=containers.Map('KeyType','double','ValueType','any');


            addlistener(obj.UIObj.SimMappingData,'BlockRemovedEvent',@obj.handleBlockRemoved);
            addlistener(obj.UIObj.RTWMappingData,'BlockRemovedEvent',@obj.handleBlockRemoved);
        end

        function mappingData=get.MappingData(obj)
            mappingData=getMappingData(obj.UIObj);
        end

        function highlightTask(obj,regionId,taskId,taskType)
            blockInfos=getBlocksByTask(obj.MappingData,regionId,taskId);
            blockPaths=arrayfun(@(x)x.Path,blockInfos,'UniformOutput',false);
            blocks=getSimulinkBlockHandle(blockPaths);
            blocks=blocks(blocks~=-1);
            if isempty(blocks)
                return
            end
            key=bitor(regionId,bitshift(taskId,32));

            if isKey(obj.HighlightedTasks,key)
                removeHighlightByStyle(obj,obj.HighlightedTasks(key));
            end
            color=getColorForTask(obj,regionId,taskId,taskType);
            options={'HighLightColor',color,'highlightstyle','SolidLine',...
            'HighlightWidth',3,'tag',['MulticoreTask',num2str(taskId)],...
            'HighlightSelectedBlocks',1};

            virtualSubsystems=multicoredesigner.internal.MappingData.getAllVirtualAncestors(blocks);
            blocks=[blocks,virtualSubsystems];

            mixedStyleBlocks=[virtualSubsystems,getMultiTaskBlocks(obj.MappingData,regionId,taskId)];

            for i=1:length(mixedStyleBlocks)
                cur=mixedStyleBlocks(i);
                if isKey(obj.MixedStyleNumTasks,cur)&&obj.MixedStyleNumTasks(cur)>1



                    removeHighlightByStyle(obj,obj.MixedTaskStyle(cur));
                    obj.MixedTaskStyle(cur)=[];
                end
            end


            obj.HighlightedTasks(key)=Simulink.Structure.Utils.highlightObjs([],blocks,options{:});


            color=getColorForTask(obj,[],[],'Multiple');
            mixedTaskOptions={'HighLightColor',color,'highlightstyle','SolidLine',...
            'HighlightWidth',3,'tag','MulticoreTaskMultiple',...
            'HighlightSelectedBlocks',1};


            for i=1:length(mixedStyleBlocks)
                cur=mixedStyleBlocks(i);
                if~isKey(obj.MixedStyleNumTasks,cur)
                    obj.MixedStyleNumTasks(cur)=1;
                    obj.MixedTaskStyle(cur)=[];
                else
                    obj.MixedStyleNumTasks(cur)=obj.MixedStyleNumTasks(cur)+1;
                    obj.MixedTaskStyle(cur)=Simulink.Structure.Utils.highlightObjs([],cur,mixedTaskOptions{:});
                end
            end

            notify(obj,'HighlightingOnEvent');
        end

        function highlightAll(obj)
            removeAllHighlighting(obj);
            numMappings=getNumMapping(obj.MappingData);
            for i=1:numMappings
                numTasks=getNumTasksBySystem(obj.MappingData,i);
                modelPath=getModelPath(obj.MappingData,i);
                parentSystem=getParentSystemName(obj.MappingData,i);
                if strcmpi(get_param(parentSystem,'Type'),'Block')&&...
                    strcmpi(get_param(parentSystem,'Type'),'SubSystem')
                    bp=Simulink.BlockPath([modelPath,{parentSystem}]);
                    bp.open;
                end
                for j=1:numTasks
                    taskType=getTaskType(obj.MappingData,i,j);
                    highlightTask(obj,i,j,taskType);
                end
            end
        end

        function removeTaskHighlight(obj,regionId,taskId)
            key=bitor(regionId,bitshift(taskId,32));
            if~isKey(obj.HighlightedTasks,key)
                return
            end



            style=obj.HighlightedTasks(key);
            removeHighlightByStyle(obj,style);
            remove(obj.HighlightedTasks,key);


            blockInfos=getBlocksByTask(obj.MappingData,regionId,taskId);
            blocks=arrayfun(@(x)(get_param(x.Path,'Handle')),blockInfos);

            virtualSubsystems=multicoredesigner.internal.MappingData.getAllVirtualAncestors(blocks);
            mixedStyleBlocks=[virtualSubsystems,getMultiTaskBlocks(obj.MappingData,regionId,taskId)];

            for i=1:length(mixedStyleBlocks)
                cur=mixedStyleBlocks(i);
                if isKey(obj.MixedStyleNumTasks,cur)
                    taskCount=obj.MixedStyleNumTasks(cur);
                    if taskCount==1
                        remove(obj.MixedStyleNumTasks,cur);
                        remove(obj.MixedTaskStyle,cur);
                    else



                        taskCount=taskCount-1;
                        if taskCount==1
                            removeHighlightByStyle(obj,obj.MixedTaskStyle(cur));
                            obj.MixedTaskStyle(cur)=[];
                        end
                        obj.MixedStyleNumTasks(cur)=taskCount;
                    end
                end
            end

            if isempty(obj.HighlightedTasks.keys)&&isempty(obj.MixedTaskStyle.keys)
                notify(obj,'HighlightingOffEvent');
            end
        end

        function removeAllHighlighting(obj)


            keys=obj.HighlightedTasks.keys;
            for i=1:length(keys)
                style=obj.HighlightedTasks(keys{i});
                removeHighlightByStyle(obj,style);
            end
            remove(obj.HighlightedTasks,keys);


            keys=obj.MixedStyleNumTasks.keys;
            for i=1:length(keys)
                if obj.MixedStyleNumTasks(keys{i})>1
                    removeHighlightByStyle(obj,obj.MixedTaskStyle(keys{i}));
                    obj.MixedTaskStyle(keys{i})=[];
                end
                remove(obj.MixedTaskStyle,keys{i});
            end
            remove(obj.MixedStyleNumTasks,keys);

            if isempty(obj.HighlightedTasks.keys)&&isempty(obj.MixedTaskStyle.keys)
                notify(obj,'HighlightingOffEvent');
            end
        end

        function removeHighlightByStyle(~,style)
            if~isempty(style)



                style.handles=style.handles(ishandle(style.handles));

                Simulink.SLHighlight.removeHighlight(style);
            end
        end

        function isHighlighted=isTaskHighlighted(obj,regionId,taskId)
            key=bitor(regionId,bitshift(taskId,32));
            isHighlighted=isKey(obj.HighlightedTasks,key);
        end

        function color=getColorForTask(obj,regionId,taskId,taskType)

            if isequal(taskType,'Init')
                color=obj.IRTColors(1,:);
            elseif isequal(taskType,'Reset')
                color=obj.IRTColors(2,:);
            elseif isequal(taskType,'Terminate')
                color=obj.IRTColors(3,:);
            elseif isequal(taskType,'Multiple')
                color=[0,0,0];
            else
                taskId=getUniqueIdForTask(obj.MappingData,regionId,taskId);
                if taskId<11
                    color=obj.ThreadColours(taskId,:);
                else
                    numTasks=getNumAllTasks(obj.MappingData);
                    max=numTasks-10;
                    offsetTaskNum=double(taskId-10);
                    cmap=parula;
                    [m,~]=size(cmap);
                    row=round(((offsetTaskNum)/max)*(m-1))+1;
                    color=cmap(row,:);
                end
            end
        end

        function onHighlightTaskEnabled(obj,~,eventData)
            if isa(eventData,multicoredesigner.internal.TaskHighlightEvent)
                highlightTask(obj,TaskHighlightEvent)
            end
        end

        function onHighlightEnableDisable(obj,~,eventData)
            if isa(eventData,multicoredesigner.internal.TaskHighlightEvent)
                if eventData.Highlight
                    highlightTask(obj,eventData.SystemId,eventData.TaskId,eventData.TaskType);
                else
                    removeTaskHighlight(obj,eventData.SystemId,eventData.TaskId);
                end
            end
        end

        function handleBlockRemoved(obj,~,~)
            removeAllHighlighting(obj);
        end
    end
end


