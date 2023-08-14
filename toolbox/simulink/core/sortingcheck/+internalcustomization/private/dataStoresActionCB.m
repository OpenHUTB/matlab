function result=dataStoresActionCB(taskobj)

    mdladvObj=taskobj.MAObj;
    checkObj=taskobj.Check;

    execInfo=checkObj.ResultData;

    [succeed,changedSystems,skippedSystems]=updateBlockOrder(execInfo);

    type=getBlockOrderCheckType(checkObj.ID);

    if(strcmp(type,'FEATUREONOFF'))
        result=generateReportForFix(succeed,changedSystems,skippedSystems,type);
    else
        assert(strcmp(type,'SIMRTW'));


        if~isempty(execInfo)
            execInfoUpdated=getDataStoreExecutionInfo(taskobj.MAObj.System,'','SIMRTW');
            succeed=isempty(execInfoUpdated);
        end
        if~succeed&&~isempty(changedSystems)
            updatedBlocks=changedSystems.UpdatedBlocks;

            for i=1:length(updatedBlocks)
                set_param(updatedBlocks(i),'Priority','');
            end
        end
        result=generateReportForFix(succeed,changedSystems,skippedSystems,type);
    end

    mdladvObj.setActionEnable(false);