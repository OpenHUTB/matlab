function[CheckIDArray,CheckSerialNumArray]=getCheckForTask(this,taskName)




    CheckIDArray={};
    CheckSerialNumArray={};


    am=Advisor.Manager.getInstance;
    quickLocalReference=am.slCustomizationDataStructure.TaskAdvisorCellArray;

    IDfound=false;

    for i=1:length(quickLocalReference)
        if strcmp(quickLocalReference{i}.ID,taskName)
            IDfound=true;
            if isa(quickLocalReference{i},'ModelAdvisor.Task')
                CheckIDArray={quickLocalReference{i}.MAC};
                CheckSerialNumArray={quickLocalReference{i}.MACIndex};
                return
            end
            CheckIDArray=quickLocalReference{i}.CheckTitleIDs;
            for j=1:length(quickLocalReference{i}.ChildrenObj)
                if(isa(quickLocalReference{i}.ChildrenObj{j},'ModelAdvisor.FactoryGroup'))
                    [CheckIDArrayRec,CheckSerialNumArrayRec]=getCheckForTask(this,quickLocalReference{i}.ChildrenObj{j}.ID);
                    for k=1:length(CheckIDArrayRec)
                        CheckIDArray{end+1}=CheckIDArrayRec{k};%#ok<*AGROW>
                    end
                    for k=1:length(CheckSerialNumArrayRec)
                        CheckSerialNumArray{end+1}=CheckSerialNumArrayRec{k};
                    end
                end
            end
            for j=1:length(quickLocalReference{i}.CheckIndex)
                CheckSerialNumArray{end+1}=str2double(quickLocalReference{i}.CheckIndex{j});
            end
            break;
        end
    end


    if~IDfound&&~contains(taskName,'_SYSTEM_By Task_')
        [CheckIDArray,CheckSerialNumArray]=getCheckForTask(this,['_SYSTEM_By Task_',taskName]);
    end