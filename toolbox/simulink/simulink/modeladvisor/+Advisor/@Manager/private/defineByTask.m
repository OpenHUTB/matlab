function nodes=defineByTask(taskCellArray,checkCellArray)







    nodes={};

    TAN=ModelAdvisor.Group('_SYSTEM_By Task');



    TAN.DisplayName=DAStudio.message('Simulink:tools:MAByTask');
    TAN.ByTaskMode=true;
    TAN.Published=true;

    TAN=modeladvisorprivate('modeladvisorutil2','SetFolderCSH',TAN);
    nodes{end+1}=TAN;


    for i=1:length(taskCellArray)

        taskCellArray{i}.Visible=update_Visibility(taskCellArray{i},checkCellArray);

        if taskCellArray{i}.Visible&&taskCellArray{i}.Published


            taskCellArray{i}.ID=['_SYSTEM_By Task_',taskCellArray{i}.ID];
            taskCellArray{i}.ByTaskMode=true;
            taskCellArray{i}.MAT=taskCellArray{i}.ID;
            taskCellArray{i}.MATIndex=i;
            taskCellArray{i}.Published=false;

            taskCellArray{i}=modeladvisorprivate('modeladvisorutil2','SetFolderCSH',taskCellArray{i});



            if(isempty(taskCellArray{i}.Children))
                for j=1:length(taskCellArray{i}.CheckIndex)
                    if checkCellArray{str2double(taskCellArray{i}.CheckIndex{j})}.Visible
                        activeNode=modeladvisorprivate('modeladvisorutil2','createTANFromCheck',checkCellArray,str2double(taskCellArray{i}.CheckIndex{j}),[taskCellArray{i}.ID,'_']);
                        activeNode.ByTaskMode=true;
                        taskCellArray{i}.Children{end+1}=activeNode.ID;
                        nodes{end+1}=activeNode;%#ok<AGROW>
                    end
                end
            else
                checkIndexCntr=1;
                for j=1:length(taskCellArray{i}.Children)
                    matchIndex=strmatch(taskCellArray{i}.Children{j},taskCellArray{i}.CheckTitleIDs,'exact');
                    if~isempty(matchIndex)
                        if checkIndexCntr<=length(taskCellArray{i}.CheckIndex)&&strcmp(taskCellArray{i}.Children{j},checkCellArray{str2double(taskCellArray{i}.CheckIndex{checkIndexCntr})}.ID)&&checkCellArray{str2double(taskCellArray{i}.CheckIndex{checkIndexCntr})}.Visible
                            activeNode=modeladvisorprivate('modeladvisorutil2','createTANFromCheck',checkCellArray,str2double(taskCellArray{i}.CheckIndex{checkIndexCntr}),[taskCellArray{i}.ID,'_']);
                            activeNode.ByTaskMode=true;
                            taskCellArray{i}.Children{j}=activeNode.ID;
                            nodes{end+1}=activeNode;%#ok<AGROW>
                            checkIndexCntr=checkIndexCntr+1;
                        end
                    else
                        taskCellArray{i}.Children{j}=['_SYSTEM_By Task_',taskCellArray{i}.Children{j}];
                    end
                end
            end

            taskCellArray{i}.ChildrenObj={};

            if~isempty(taskCellArray{i}.Children)
                if taskCellArray{i}.Top

                    TAN.Children{end+1}=taskCellArray{i}.ID;
                end
                nodes{end+1}=taskCellArray{i};%#ok<AGROW>
            end
        end
    end


    if isempty(TAN.Children)
        nodes={};
    end

    function visible=update_Visibility(myFactoryGroup,checkCellArray)
        visible=0;
        if~(myFactoryGroup.Visible)
            return;
        end
        for i=1:length(myFactoryGroup.CheckIndex)
            if(checkCellArray{str2double(myFactoryGroup.CheckIndex{i})}.Visible)
                visible=1;
                return;
            end
        end
        for j=1:length(myFactoryGroup.ChildrenObj)
            visible=update_Visibility(myFactoryGroup.ChildrenObj{j},checkCellArray);
            if(visible)
                return;
            end
        end
