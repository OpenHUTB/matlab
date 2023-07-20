function result=justifyCheck(modelName,checkID,runCheck)









    if nargin<=2
        runCheck=false;
    end

    if runCheck
        ModelAdvisor.run(modelName,{checkID});
    end


    result=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(modelName);
    checkObj=mdladvObj.getCheckObj(checkID);


    violations=checkObj.ResultDetails;

    if(checkObj.status==ModelAdvisor.CheckStatus.Passed)||isempty(violations)
        disp(['There are no violations reported in this Check:',checkID]);
        result='Pass';
        return;
    end

    display(newline);
    disp(['The following elements are violating the Check: ',checkID,newline]);

    for idx=1:numel(violations)
        disp([num2str(idx),'. '...
        ,slcheck.getFullPathFromSID(violations(idx).Data)]);
    end

    qu=numel(violations)+1;
    disp([num2str(qu),'. Quit']);

    index=input([newline,'Enter the serial number elements you would like to justify:',newline]);
    if index==qu
        result='Quit';
        return;
    end

    reason=input(['Type the reason for justification:',newline],'s');

    manager=slcheck.getAdvisorFilterManager(modelName);
    result=manager.justifyCheck(slcheck.getsid(violations(index).Data),...
    reason,checkID);


end

