function loadslCustomization(this)










    cm=DAStudio.CustomizationManager;
    if isempty(cm.getModelAdvisorCheckFcns)
        sl_refresh_customizations;
    end

    h=Simulink.PluginMgr;
    h.ExecuteModelAdvisorCustomizations;

    h1=DAServiceManager.OnDemandService;
    h1.Start('ModelAdv');
    maRoot=ModelAdvisor.Root();



    PerfTools.Tracer.logMATLABData('MAGroup','Load Checks',true);
    [checks,this.slCustomizationDataStructure.CheckIDMap]=this.collectChecksAndTasks();






    tasks=calculateCheckIndex(this,maRoot.TaskList);
    PerfTools.Tracer.logMATLABData('MAGroup','Load Checks',false);





    PerfTools.Tracer.logMATLABData('MAGroup','Load TaskAdvisors',true);
    maRoot.setCheckInfo(this.slCustomizationDataStructure.CheckIDMap);
    taskAdvisorInfo=collectTaskAdvisorTasks(this);




    this.slCustomizationDataStructure.callbackFuncInfoStruct=gatherCallbackFuncInfo();
    this.slCustomizationDataStructure.callbackFuncInfoStruct.TaskAdvisorInfo=taskAdvisorInfo;


    if~isempty(cm.getModelAdvisorProcessFcns())
        customizedChecks=copyCellArray(checks);
        customizedTasks=copyCellArray(tasks);
        nodesCopy=copyCellArray(maRoot.getTaskAdvisorNodes());


        [customizedChecks,customizedTasks]=...
        applyProcessCallback(customizedChecks,customizedTasks);

        customizationData=createDataModel(customizedChecks,customizedTasks);

        this.slCustomizationDataStructure=mixin(this.slCustomizationDataStructure,customizationData);


        maRoot.resetCollectedNodes(nodesCopy);

        this.slCustomizationDataStructure.DefaultCustomizationData=createDataModel(checks,tasks);




        assert(numel(checks)==numel(customizedChecks),...
        'Checks may not be removed or added in the process callback.');







        this.slCustomizationDataStructure.checkCellArray=customizedChecks;

        this.slCustomizationDataStructure.DefaultCustomizationData=...
        rmfield(this.slCustomizationDataStructure.DefaultCustomizationData,'checkCellArray');

    else
        customizationData=createDataModel(checks,tasks);
        this.slCustomizationDataStructure=mixin(this.slCustomizationDataStructure,customizationData);
    end


    this.slCustomizationDataStructure.callbackFuncInfoStruct.Hash=getCustomizationHash(this.slCustomizationDataStructure);



    maRoot.clear();

    PerfTools.Tracer.logMATLABData('MAGroup','Load TaskAdvisors',false);
end

function customizationData=createDataModel(checks,tasks)

    groupedrecordTree=createByProductGroupStructure(checks);


    loc_setSelected(checks,tasks);


    customizationData.GroupedrecordTree=...
    loc_setEnability(groupedrecordTree,checks);


    customizationData.checkCellArray=checks;
    customizationData.taskCellArray=tasks;


    [customizationData.topLevelWorkFlows,...
    customizationData.TaskAdvisorCellArray,...
    customizationData.libtopLevelWorkFlows,...
    customizationData.LibTaskAdvisorCellArray,...
    customizationData.TaskAdvisorIDMap]=...
    createTaskTree(customizationData.GroupedrecordTree,checks,tasks);
end



function arraycopy=copyCellArray(array)
    arraycopy=cell(size(array));
    for n=1:length(array)
        arraycopy{n}=copy(array{n});
    end
end

function c=mixin(a,b)
    k=fieldnames(b);
    for i=1:length(k)
        if~isfield(a,k{i})||isa(a.(k{i}),'containers.Map')
            a.(k{i})=b.(k{i});
        end
    end

    c=a;
end

function groupedrecordTree=createByProductGroupStructure(checks)

    groupedrecordTree={};
    for i=1:length(checks)
        if checks{i}.Visible


            cacheCopy=checks{i}.Group;
            if iscell(cacheCopy)
                for c=1:length(cacheCopy)
                    checks{i}.Group=cacheCopy{c};
                    groupedrecordTree=loc_add_record_into_tree(groupedrecordTree,checks{i});
                end
            else
                groupedrecordTree=loc_add_record_into_tree(groupedrecordTree,checks{i});
            end
            checks{i}.Group=cacheCopy;
        end
    end
end

function callbackFuncInfoStruct=gatherCallbackFuncInfo()
    maRoot=ModelAdvisor.Root;
    cm=DAStudio.CustomizationManager;

    callbackFuncInfoStruct=[];
    allCallBackFcnListName=maRoot.allCallBackFcnListName;
    taskCallBackFcnListName=maRoot.taskCallBackFcnListName;

    callbackFuncInfoStruct.CheckInfo={};
    for i=1:length(allCallBackFcnListName)
        callbackFuncInfoStruct.CheckInfo{end+1}=dir(allCallBackFcnListName{i});
    end

    callbackFuncInfoStruct.TaskInfo={};
    for i=1:length(taskCallBackFcnListName)
        callbackFuncInfoStruct.TaskInfo{end+1}=dir(taskCallBackFcnListName{i});
    end

    callbackFuncInfoStruct.ProcessCallbackInfo={};
    processCallBackFunListName=cm.getModelAdvisorProcessFcnsName;
    for i=1:length(processCallBackFunListName)
        callbackFuncInfoStruct.ProcessCallbackInfo{end+1}=dir(processCallBackFunListName{i}(1).file);
    end
end



function outputTree=loc_setEnability(mytree,recordCellArray)
    if~isempty(mytree)
        mytree.Disabled=false;
        for i=1:length(mytree.Nodes)
            ni=mytree.Nodes{i};
            if~ni
                continue
            end
            if~recordCellArray{ni}.Enable
                mytree.Disabled=true;
                break
            end
        end
        for i=1:length(mytree.Groups)
            mytree.Groups{i}=loc_setEnability(mytree.Groups{i},recordCellArray);
            if mytree.Groups{i}.Disabled
                mytree.Disabled=true;
            end
        end
    end
    outputTree=mytree;
end

function outputTree=loc_add_record_into_tree(inputTree,newNode)

    if~isfield(inputTree,'Groups')
        inputTree.Groups={};
    end
    if~isfield(inputTree,'Nodes')
        inputTree.Nodes={};
    end
    if~isempty(deblank(newNode.Group))
        [groupName,newNode.Group]=loc_analyze_group(newNode.Group);
        [inputTree,index]=loc_add_group_into_tree(inputTree,groupName);
        inputTree.Groups{index}=loc_add_record_into_tree(inputTree.Groups{index},newNode);
    else
        inputTree.Nodes{end+1}=newNode.Index;
    end
    outputTree=inputTree;
end

function[outputTree,index]=loc_add_group_into_tree(inputTree,groupName)
    for i=1:length(inputTree.Groups)
        if strcmp(inputTree.Groups{i}.name,groupName)

            outputTree=inputTree;
            index=i;
            return
        end
    end

    newGroup.name=groupName;
    newGroup.Groups={};
    newGroup.Nodes={};
    inputTree.Groups{end+1}=newGroup;
    outputTree=inputTree;
    index=length(inputTree.Groups);
end

function[firstPart,remainder]=loc_analyze_group(groupName)
    idx=strfind(groupName,'|');
    if isempty(idx)||idx(1)==1
        firstPart=groupName;
        remainder='';
    else
        firstPart=groupName(1:idx(1)-1);
        remainder=groupName(idx(1)+1:end);
    end
end


function loc_setSelected(CheckCellArray,TaskCellArray)


    allChecksBelongtoTask={};
    for i=1:length(TaskCellArray)
        [NumRowsTitleIDs,~]=size(TaskCellArray{i}.CheckTitleIDs);
        if NumRowsTitleIDs>1
            allChecksBelongtoTask=[allChecksBelongtoTask,TaskCellArray{i}.CheckTitleIDs'];%#ok<AGROW>
        else
            allChecksBelongtoTask=[allChecksBelongtoTask,TaskCellArray{i}.CheckTitleIDs];%#ok<AGROW>
        end
    end
    allChecksBelongtoTask=unique(allChecksBelongtoTask);
    for i=1:length(CheckCellArray)
        if CheckCellArray{i}.Visible

            CheckCellArray{i}.Selected=CheckCellArray{i}.Value;
            if ismember(CheckCellArray{i}.ID,allChecksBelongtoTask)


                CheckCellArray{i}.SelectedByTask=CheckCellArray{i}.Value;
            end
        else
            CheckCellArray{i}.Selected=false;
            CheckCellArray{i}.SelectedByTask=false;
            CheckCellArray{i}.Enable=false;
        end
    end
    for i=1:length(TaskCellArray)
        if TaskCellArray{i}.Visible
            TaskCellArray{i}.Selected=TaskCellArray{i}.Value;
        else
            TaskCellArray{i}.Selected=false;
            TaskCellArray{i}.Enable=false;
        end
    end
end





function TaskList=calculateCheckIndex(this,TaskList)

    for taskCt=1:length(TaskList)
        activeRecord=TaskList{taskCt};


        CheckTitleIDs=activeRecord.CheckTitleIDs;
        for i=1:length(CheckTitleIDs)
            if this.slCustomizationDataStructure.CheckIDMap.isKey(CheckTitleIDs{i})
                activeRecord.CheckIndex{end+1}=num2str(this.slCustomizationDataStructure.CheckIDMap(CheckTitleIDs{i}));
                noMatchFound=false;
            else
                noMatchFound=true;
            end

            if noMatchFound
                newID=ModelAdvisor.convertCheckID(CheckTitleIDs{i});
                if~isempty(newID)
                    modeladvisorprivate('modeladvisorutil2','WarnOldCheckID',CheckTitleIDs{i},newID);
                    activeRecord.CheckTitleIDs{i}=newID;
                    if this.slCustomizationDataStructure.CheckIDMap.isKey(CheckTitleIDs{i})
                        activeRecord.CheckIndex{end+1}=num2str(this.slCustomizationDataStructure.CheckIDMap(CheckTitleIDs{i}));
                    end
                end
            end
        end
    end
end
