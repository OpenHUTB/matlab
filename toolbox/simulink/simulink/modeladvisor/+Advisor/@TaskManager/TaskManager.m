classdef TaskManager<handle





    properties(SetAccess=private)
        AdvisorRootId='';
        IsInitialized=false;
        ConfigFilePath=[];
    end

    properties(SetAccess=private,Hidden)



        NodeIDMap;



        TaskIDMap;

        TaskInfo=[];

        ApplicationObj;
    end


    properties(Dependent=true,SetAccess=private,Hidden)
        RootCompId;
    end





    methods


        function value=get.RootCompId(this)
            value=this.ApplicationObj.AnalysisRootComponentId;
        end



        function set.RootCompId(~,~)
        end









        function this=TaskManager(taskAdvisorRoot,appObj)



            this.AdvisorRootId=taskAdvisorRoot;

            this.ApplicationObj=appObj;

            this.NodeIDMap=containers.Map('KeyType','char','ValueType','any');
            this.TaskIDMap=containers.Map('KeyType','char','ValueType','any');
        end








        function taskIDs=getSelectedTasks(this,varargin)
            p=inputParser();
            p.addParameter('compileMode',[],@(x)isa(x,'Advisor.CompileModes'));
            p.addParameter('GroupID','',@(x)ischar(x));
            p.parse(varargin{:});
            inputs=p.Results;

            if this.IsInitialized
                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};

                if isempty(inputs.GroupID)
                    rootNode=maObj.TaskAdvisorRoot;
                else
                    rootNode=maObj.getTaskObj(inputs.GroupID);
                end


                taskIDs=this.parseTreeForSelection(...
                rootNode,inputs.compileMode,true,true);
            else
                taskIDs={};
            end
        end

        function indices=taskIDs2Indices(this,taskIDs)
            if this.IsInitialized
                indices=cell(size(taskIDs));

                for n=1:length(taskIDs)
                    if this.TaskIDMap.isKey(taskIDs{n})
                        indices{n}=this.TaskIDMap(taskIDs{n});
                    else
                        DAStudio.error('Advisor:base:Tasks_UnknownTask',taskIDs{n});
                    end
                end
            else
                indices={};
            end
        end

        function modes=getRequiredCompileModes(this,selectedTasks)
            modes=Advisor.CompileModes.empty();

            if this.IsInitialized
                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};

                for n=length(selectedTasks):-1:1
                    idx=this.TaskIDMap(selectedTasks{n});
                    check=maObj.TaskAdvisorCellArray{idx}.Check;
                    modes(n)=Advisor.CompileModes.char2mode(check.CallbackContext);
                end

                modes=unique(modes);
            end
        end







        function tasks=getTasks(nodeID)
            tasks={};

            if this.IsInitialized
                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};

                node=maObj.getTaskObj(nodeID);

                if isa(node,'ModelAdvisor.Group')
                    tasks=Advisor.TaskManager.getChildTasks(node);
                end
            end
        end








        function selectedIds=getSelectedNodes(this)
            if this.IsInitialized
                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};


                selectedIds=this.parseTreeForSelection(...
                maObj.TaskAdvisorRoot,[],false,false);
            else
                selectedIds={};
            end
...
...
...
...
...
...
...
...
...
...
...
...
        end










        function selectTask(this,id,status)
            if this.IsInitialized
                if~this.NodeIDMap.isKey(id)
                    DAStudio.error('Advisor:base:Tasks_UnknownTask',id);
                end

                idx=this.NodeIDMap(id);
                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};
                maObj.TaskAdvisorCellArray{idx}.changeSelectionStatus(status);

            end
        end









        function selectAllTasks(this,status)
            if this.IsInitialized
                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};
                maObj.TaskAdvisorRoot.changeSelectionStatus(status);
            end
        end









        function status=isNodeSelected(this,id)
            if this.IsInitialized

                if~this.NodeIDMap.isKey(id)
                    DAStudio.error('Advisor:base:Tasks_UnknownTask',id);
                end

                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};
                node=maObj.TaskAdvisorCellArray{this.NodeIDMap(id)};

                status=node.Selected;
            else
                status=false;
            end

...
...
...
...
...
...
...
...
...
        end








        function status=isNodeInTriState(this,id)
            if this.IsInitialized

                if~this.NodeIDMap.isKey(id)
                    DAStudio.error('Advisor:base:Tasks_UnknownTask',id);
                end

                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};
                node=maObj.TaskAdvisorCellArray{this.NodeIDMap(id)};

                status=node.InTriState;
            else
                status=false;
            end
...
...
...
...
...
...
...
...
...
        end









        function clearResults(this)



            this.NodeIDMap=containers.Map('KeyType','char','ValueType','any');
            this.TaskIDMap=containers.Map('KeyType','char','ValueType','any');

            this.TaskInfo=[];
        end


        sysResult=getComponentResult(this,compId)






        function ids=getTaskIDs(this,varargin)
            ids={};

            if isempty(varargin)
                ids=this.TaskIDMap.keys;
            else
                checkIDs=varargin{1};
                indices=this.TaskIDMap.values;
                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};
                taca=maObj.TaskAdvisorCellArray;

                for n=1:length(indices)
                    task=taca{indices{n}};

                    if any(strcmp(checkIDs,task.MAC))
                        ids{end+1}=task.ID;%#ok<AGROW>
                    end
                end
            end
        end
    end





    methods(Hidden)














        function info=getTaskInfoForExecution(this)
            if isempty(this.TaskInfo)
                info=this.cacheTaskInfo();
            else
                info=this.TaskInfo;
            end
        end

        function info=cacheTaskInfo(this)
            info=[];

            if~isempty(this.RootCompId)
                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};

                info.regularTaskCompileInfo.TaskIdList={};
                info.regularTaskCompileInfo.TaskIdxList={};
                info.regularTaskCompileInfo.ModeList=Advisor.CompileModes.empty();
                info.procedureTaskCompileInfo={};


                info=this.parseTreeBeforeExecution(...
                maObj.TaskAdvisorRoot,false,info);


                info.regularTaskCompileInfo.UniqueModes=...
                unique(info.regularTaskCompileInfo.ModeList);



                for n=1:length(info.procedureTaskCompileInfo)

                    info.procedureTaskCompileInfo{n}.ModeChangeIndices=1;

                    for ni=2:length(info.procedureTaskCompileInfo{n}.ModeList)




                        validModeChange=true;

                        if info.procedureTaskCompileInfo{n}.ModeList(ni)==...
                            Advisor.CompileModes.None

                            validModeChange=false;
                        end

                        if validModeChange


                            lastActualModeChange=...
                            info.procedureTaskCompileInfo{n}.ModeList(...
                            info.procedureTaskCompileInfo{n}.ModeChangeIndices(end));

                            if info.procedureTaskCompileInfo{n}.ModeList(ni)~=...
lastActualModeChange


                                info.procedureTaskCompileInfo{n}.ModeChangeIndices(end+1)=ni;
                            end
                        end
                    end
                end


                this.TaskInfo=info;
            end
        end


        function checkIDs=getChecksScheduledForExecution(this)
            info=this.getTaskInfoForExecution();

            if~isempty(info)

                idx=info.regularTaskCompileInfo.TaskIdxList;

                for n=1:length(info.procedureTaskCompileInfo)
                    idx=[idx,info.procedureTaskCompileInfo{n}.TaskIdxList];%#ok<AGROW>
                end
                idx=unique([idx{:}]);

                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};
                taca=maObj.TaskAdvisorCellArray;

                checkIDs=cell(size(idx));
                for n=1:length(idx)
                    if isa(taca{idx(n)}.Check,'ModelAdvisor.Check')
                        checkIDs{n}=taca{idx(n)}.Check.ID;
                    end
                end

                checkIDs=unique(checkIDs);
            else
                checkIDs={};
            end
        end




        function registerCGIRInspectorsForSelectedTasks(this)
            taskInfo=this.getTaskInfoForExecution();


            taskList=taskInfo.regularTaskCompileInfo.TaskIdxList;
            taskIdx=taskList(taskInfo.regularTaskCompileInfo.ModeList==...
            Advisor.CompileModes.CGIR);


            for n=1:length(taskInfo.procedureTaskCompileInfo)
                tempTaskList=taskInfo.procedureTaskCompileInfo{n}.TaskIdxList;
                tempTaskIdx=tempTaskList(...
                taskInfo.procedureTaskCompileInfo{n}.ModeList==Advisor.CompileModes.CGIR);

                if~isempty(tempTaskIdx)
                    taskIdx=[taskIdx,tempTaskIdx];%#ok<AGROW>
                end
            end


            if~isempty(taskIdx)


                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};
                checkIDs=cell(size(taskIdx));

                for n=1:length(taskIdx)
                    checkIDs{n}=maObj.TaskAdvisorCellArray{taskIdx{n}}.Check.ID;
                end

                Advisor.RegisterCGIRInspectors.getInstance.addInspectors(checkIDs);
            end
        end

        function registerSLDVOptionsForSelectedTasks(this)
            taskInfo=this.getTaskInfoForExecution();


            taskList=taskInfo.regularTaskCompileInfo.TaskIdxList;
            taskIdx=taskList(taskInfo.regularTaskCompileInfo.ModeList==...
            Advisor.CompileModes.SLDV);


            for n=1:length(taskInfo.procedureTaskCompileInfo)
                tempTaskList=taskInfo.procedureTaskCompileInfo{n}.TaskIdxList;
                tempTaskIdx=tempTaskList(...
                taskInfo.procedureTaskCompileInfo{n}.ModeList==Advisor.CompileModes.SLDV);

                if~isempty(tempTaskIdx)
                    taskIdx=[taskIdx,tempTaskIdx];%#ok<AGROW>
                end
            end


            if~isempty(taskIdx)


                maObj=this.getMAObjs(this.RootCompId);
                maObj=maObj{1};
                checks=cell(size(taskIdx));

                for n=1:length(taskIdx)
                    checks{n}=maObj.TaskAdvisorCellArray{taskIdx{n}}.Check.ID;
                end

                Advisor.SLDVCompileService.getInstance.registerSLDVChecks(checks);
            end
        end

        function setConfigFilePath(this,ConfigFilePath)
            this.ConfigFilePath=ConfigFilePath;
        end

    end




    methods(Access=private)




        function generateIDMap(this,node)
            if isa(node,'ModelAdvisor.Task')&&isa(node.Check,'ModelAdvisor.Check')
                this.NodeIDMap(node.ID)=node.Index;
                this.TaskIDMap(node.ID)=node.Index;

            elseif isa(node,'ModelAdvisor.Group')

                this.NodeIDMap(node.ID)=node.Index;


                for n=1:length(node.ChildrenObj)
                    this.generateIDMap(node.ChildrenObj{n});
                end
            else

            end
        end


        function info=parseTreeBeforeExecution(this,node,inProcedure,info)

            if isa(node,'ModelAdvisor.Task')&&isa(node.Check,'ModelAdvisor.Check')





                if inProcedure

                    info.procedureTaskCompileInfo{end}.TaskIdList{end+1}=...
                    node.Id;
                    info.procedureTaskCompileInfo{end}.TaskIdxList{end+1}=...
                    node.Index;
                    info.procedureTaskCompileInfo{end}.ModeList(end+1)=...
                    Advisor.CompileModes.char2mode(node.Check.CallbackContext);

                else
                    if node.Selected

                        info.regularTaskCompileInfo.TaskIdList{end+1}=node.Id;
                        info.regularTaskCompileInfo.TaskIdxList{end+1}=node.Index;
                        info.regularTaskCompileInfo.ModeList(end+1)=...
                        Advisor.CompileModes.char2mode(node.Check.CallbackContext);
                    end
                end

            elseif isa(node,'ModelAdvisor.Group')


                if node.Selected||inProcedure||strcmp(node.ID,'SysRoot')
                    if isa(node,'ModelAdvisor.Procedure')


                        if~inProcedure
                            info.procedureTaskCompileInfo{end+1}.TaskIdList={};
                            info.procedureTaskCompileInfo{end}.TaskIdxList={};
                            info.procedureTaskCompileInfo{end}.Id=node.Id;
                            info.procedureTaskCompileInfo{end}.Index=node.Index;
                            info.procedureTaskCompileInfo{end}.ModeList=Advisor.CompileModes.empty();
                        end

                        inProcedure=true;
                    end


                    for n=1:length(node.ChildrenObj)

                        info=this.parseTreeBeforeExecution(...
                        node.ChildrenObj{n},inProcedure,info);

                    end
                end

            else

            end
        end


        function ids=parseTreeForSelection(this,node,compileMode,onlyTasks,skipProcedures)
            ids={};

            if isa(node,'ModelAdvisor.Task')&&isa(node.Check,'ModelAdvisor.Check')
                if node.Selected
                    if isempty(compileMode)
                        ids={node.ID};
                    elseif strcmp(node.Check.CallbackContext,compileMode.char())
                        ids={node.ID};
                    else
                        ids={};
                    end
                else
                    ids={};
                end
            elseif isa(node,'ModelAdvisor.Group')
                if skipProcedures&&isa(node,'ModelAdvisor.Procedure')

                    ids={};
                else
                    if~onlyTasks&&node.Selected
                        ids={node.ID};
                    else
                        ids={};
                    end


                    for n=1:length(node.ChildrenObj)

                        tempIds=this.parseTreeForSelection(node.ChildrenObj{n},...
                        compileMode,onlyTasks,skipProcedures);
                        ids=[ids,tempIds];%#ok<AGROW>
                    end
                end
            else

            end
        end



        function mas=getMAObjs(this,varargin)
            if isempty(varargin)
                mas=this.ApplicationObj.getMAObjs();
            else
                compId=varargin{1};

                mas=this.ApplicationObj.getMAObjs(compId);
            end

        end
    end

    methods(Access=private,Static)
        function tasks=getChildTasks(group)
            tasks={};

            for n=1:length(group.ChildrenObj)
                child=group.ChildrenObj(n);

                if isa(child,'ModelAdvisor.Group')
                    tasks=[tasks,Advisor.TaskManager.getChildTasks(child)];%#ok<AGROW>
                elseif isa(child,'ModelAdvisor.Task')
                    tasks{end+1}=child;%#ok<AGROW>
                end
            end
        end
    end
end