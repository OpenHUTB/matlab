function[topLevelWorkFlows,taskAdvisorCellArray,...
    libtopLevelWorkFlows,librecordCellArray,taskAdvisorIDMap]=...
    createTaskTree(groupedrecordTree,checkCellArray,taskCellArray)





    maRoot=ModelAdvisor.Root();










    nodesArray=maRoot.getTaskAdvisorNodes();








    nodes=defineByProduct(groupedrecordTree,checkCellArray);
    maRoot.register(nodes,fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','+Advisor','@Manager','private','defineByProduct'));


    nodes=defineByTask(taskCellArray,checkCellArray);
    maRoot.register(nodes,fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','+Advisor','@Manager','private','defineByTask'));


    byProductAndByTask=maRoot.getTaskAdvisorNodes();


    taskAdvisorCellArray=[byProductAndByTask(length(nodesArray)+1:end),nodesArray];



    applyCheckPropertiesToTasks(checkCellArray,taskAdvisorCellArray);


    mp=ModelAdvisor.Preferences;
    if mp.DeselectByProduct
        for i=1:length(taskAdvisorCellArray)
            if strncmp(taskAdvisorCellArray{i}.ID,'_SYSTEM_By Product',18)
                taskAdvisorCellArray{i}.Selected=false;
            end
        end
    end

    librecordCellArray=taskAdvisorCellArray;
    [libtopLevelWorkFlows,librecordCellArray]=linknodes(librecordCellArray);


    byTaskIdx=[];
    for ii=1:length(libtopLevelWorkFlows)
        if strcmp(librecordCellArray{libtopLevelWorkFlows{ii}}.ID,'_SYSTEM_By Task')
            byTaskIdx=ii;
            break;
        end
    end

    if~isempty(byTaskIdx)
        MAABFolder=-1;
        JMAABFolder=-1;
        sortIdx=cell(1,length(librecordCellArray{libtopLevelWorkFlows{byTaskIdx}}.ChildrenObj));

        for ii=1:length(librecordCellArray{libtopLevelWorkFlows{byTaskIdx}}.ChildrenObj)
            sortIdx{ii}=librecordCellArray{libtopLevelWorkFlows{byTaskIdx}}.ChildrenObj{ii}.DisplayName;
            if strcmp(sortIdx{ii},DAStudio.message('ModelAdvisor:styleguide:MAABChecks'))
                MAABFolder=ii;
            end
            if strcmp(sortIdx{ii},DAStudio.message('ModelAdvisor:styleguide:JMAABChecks'))
                JMAABFolder=ii;
            end
        end

        [~,idx]=sort(sortIdx);


        if(MAABFolder>0)&&(JMAABFolder>0)
            [~,newMAABLocation]=ismember(MAABFolder,idx);
            [~,newJMAABLocation]=ismember(JMAABFolder,idx);
            if newMAABLocation>newJMAABLocation
                idx(newMAABLocation)=JMAABFolder;
                idx(newJMAABLocation)=MAABFolder;
            end
        end

        librecordCellArray{libtopLevelWorkFlows{byTaskIdx}}.ChildrenIndex=librecordCellArray{libtopLevelWorkFlows{byTaskIdx}}.ChildrenIndex(idx);
    end


    topLevelWorkFlows=libtopLevelWorkFlows;
    taskAdvisorCellArray=librecordCellArray;


    taskAdvisorIDMap=containers.Map();
    for n=1:length(taskAdvisorCellArray)
        taskAdvisorIDMap(taskAdvisorCellArray{n}.ID)=n;
    end
    maRoot.clear('NodeList');
end


function applyCheckPropertiesToTasks(checks,taskAdvisorCellArray)

    for n=1:length(taskAdvisorCellArray)
        node=taskAdvisorCellArray{n};

        if isa(node,'ModelAdvisor.Node')
            if isa(node,'ModelAdvisor.Task')
                task=node;
                check=checks{task.MACIndex};


                if task.ByTaskMode
                    task.Selected=check.SelectedByTask;
                else
                    task.Selected=check.Selected;
                end

                if isempty(task.DisplayName)
                    task.DisplayName=check.Title;
                end

                if isempty(task.CSHParameters)
                    task.CSHParameters=check.CSHParameters;
                end
            end


            if~isempty(node.Value)
                node.Selected=node.Value;
            elseif isa(node,'ModelAdvisor.Group')


                node.Selected=true;
            end
        end
    end
end