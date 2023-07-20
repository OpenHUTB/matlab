function numOfSelected=selectChecks(cgo,op,cs)





    cgo.Enable=true;
    cgo.ShowCheckbox=false;

    if isempty(op)
        cgo.ChildrenObj={};
        cgo.Children={};
        numOfSelected=0;

    else

        taskMap=coder.advisor.internal.MACGOPreCheck(cgo.CGONum,op,cs);
        numOfSelected=taskMap.length;
        cgo.ChildrenObj={};
        cgo.Children={};
        taskIDs=taskMap.values;

        for i=1:numOfSelected
            taskID=taskIDs{i};
            if cgo.TaskMap.isKey(taskID)
                taskIndex=cgo.TaskMap(taskID);
                taskObj=cgo.MAObj.TaskAdvisorCellarray{taskIndex};
                assert(taskObj.Index==taskIndex);
                cgo.ChildrenObj{end+1}=taskObj;
                cgo.Children{end+1}=taskID;



                taskObj.Enable=true;
                taskObj.ShowCheckbox=false;
            end
        end

        if~strcmp(cgo.runMode,'rtwgen')
            if length(cgo.ChildrenObj)>1
                cgo.ChildrenObj{1}.State=ModelAdvisor.CheckStatus.NotRun;
                cgo.ChildrenObj{1}.StateIcon=cgo.ChildrenObj{1}.getDisplayIcon;
            end
        end

        numOfSelected=length(cgo.Children);
    end


