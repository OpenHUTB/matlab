function[TaskAdvisorCellArray,CheckCellArray,skippedElements]=createCheckObjForTree(maobj,TaskAdvisorCellArray,CheckCellArray,skippedElements,needLoadInputparamFromConfigUICellArray,NeedSupportLib,ForceRunOnLibrary)
    am=Advisor.Manager.getInstance;
    p=am.slCustomizationDataStructure.checkCellArray;
    for i=1:length(TaskAdvisorCellArray)
        if isa(TaskAdvisorCellArray{i},'ModelAdvisor.Task')
            currentTAObj=TaskAdvisorCellArray{i};
            checkIndex=currentTAObj.MACIndex;
            if checkIndex>0
                skippedElements(checkIndex)=false;
                currentTAObj.Check=copy(p{checkIndex});

                if~isempty(currentTAObj.InputParameters)&&~isempty(currentTAObj.Check.InputParameters)
                    if length(currentTAObj.InputParameters)==length(currentTAObj.Check.InputParameters)
                        for j=1:length(currentTAObj.Check.InputParameters)
                            if strcmp(currentTAObj.Check.InputParameters{j}.Name,currentTAObj.InputParameters{j}.Name)
                                currentTAObj.Check.InputParameters{j}.Value=currentTAObj.InputParameters{j}.Value;
                                currentTAObj.Check.InputParameters{j}.Visible=currentTAObj.InputParameters{j}.Visible;
                                currentTAObj.Check.InputParameters{j}.Enable=currentTAObj.InputParameters{j}.Enable;
                            end
                        end
                    else
                        DAStudio.warning('ModelAdvisor:engine:MAOutOfDateCustomization');
                    end
                end

                if needLoadInputparamFromConfigUICellArray&&~isempty(currentTAObj.Check.InputParameters)
                    if length(currentTAObj.Check.InputParameters)==length(maobj.ConfigUICellArray{i}.InputParameters)
                        for j=1:length(currentTAObj.Check.InputParameters)
                            currentTAObj.Check.InputParameters{j}.Value=maobj.ConfigUICellArray{i}.InputParameters{j}.Value;
                            currentTAObj.Check.InputParameters{j}.Visible=maobj.ConfigUICellArray{i}.InputParameters{j}.Visible;
                            currentTAObj.Check.InputParameters{j}.Enable=maobj.ConfigUICellArray{i}.InputParameters{j}.Enable;
                        end
                    else
                        for j=1:length(maobj.ConfigUICellArray{i}.InputParameters)
                            for k=1:length(currentTAObj.Check.InputParameters)
                                if strcmp(currentTAObj.Check.InputParameters{k}.Name,maobj.ConfigUICellArray{i}.InputParameters{j}.Name)
                                    currentTAObj.Check.InputParameters{k}.Value=maobj.ConfigUICellArray{i}.InputParameters{j}.Value;
                                    currentTAObj.Check.InputParameters{k}.Visible=maobj.ConfigUICellArray{i}.InputParameters{j}.Visible;
                                    currentTAObj.Check.InputParameters{k}.Enable=maobj.ConfigUICellArray{i}.InputParameters{j}.Enable;
                                    break
                                end
                            end
                        end
                    end
                end
                if NeedSupportLib
                    if~currentTAObj.Check.SupportLibrary&&~ForceRunOnLibrary
                        currentTAObj.Check.Selected=false;
                        currentTAObj.Check.SelectedByTask=false;
                        currentTAObj.Check.Enable=false;
                        currentTAObj.Enable=false;
                        currentTAObj.Selected=false;
                    end
                end

                CheckID=currentTAObj.Check.ID;
                if maobj.CheckIDToTaskMap.isKey(CheckID)
                    maobj.CheckIDToTaskMap(CheckID)=[maobj.CheckIDToTaskMap(CheckID),i];

                    if strncmp('_SYSTEM_By Product',currentTAObj.ID,length('_SYSTEM_By Product'))

                        CheckCellArray{checkIndex}=currentTAObj.Check;
                        maobj.FastCheckAccessTable(checkIndex)=currentTAObj.Index;
                    end
                else
                    maobj.CheckIDToTaskMap(CheckID)=i;


                    CheckCellArray{checkIndex}=currentTAObj.Check;
                    maobj.FastCheckAccessTable(checkIndex)=currentTAObj.Index;
                end
            else
                currentTAObj.updateStates(ModelAdvisor.CheckStatus.Failed,'fastmode');
            end
        end
    end
end