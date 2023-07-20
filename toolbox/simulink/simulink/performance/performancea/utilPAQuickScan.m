function utilPAQuickScan(group)




    MAObj=group.MAObj;
    MAObj.UserData.Mode='QuickScan';



    allChildren=group.getAllChildren();
    oldSelectedValue=zeros(1,length(allChildren));





    for i=1:length(allChildren)
        oldSelectedValue(i)=allChildren{i}.Selected;
        taskID=allChildren{i}.ID;
        checkID=allChildren{i}.MAC;
        check=MAObj.getCheckObj(checkID);
        if(strcmp(check.CallbackContext,'None')...
            &&~(strcmp(taskID,'com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline')...
            ||strcmp(taskID,'com.mathworks.Simulink.AdvisorRealTime.Baseline')));
            selected=true;
        else
            selected=false;
        end
        selected=selected&&oldSelectedValue(i);
        allChildren{i}.Selected=selected;

    end


    runTaskAdvisor(group);



    for i=1:length(allChildren)
        allChildren{i}.Selected=oldSelectedValue(i);
        allChildren{i}.changeSelectionStatus(oldSelectedValue(i));
    end


    MAObj.UserData.Mode='Full';