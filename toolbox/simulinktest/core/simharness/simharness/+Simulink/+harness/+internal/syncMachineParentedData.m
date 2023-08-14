function dstMachineId=syncMachineParentedData(blkHandle,srcBDHandle,dstBDHandle)




    dstMachineId=-1;

    try
        if~license('test','Stateflow')
            return;
        end



        insideHarnessBlocks=find_system(blkHandle,'LookUnderMasks','all','FollowLinks','off',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'MaskType','Stateflow');


        if isempty(insideHarnessBlocks)
            return;
        end

        rt=sfroot;
        srcMachine=rt.find('-isa','Stateflow.Machine','Name',get_param(srcBDHandle,'Name'));


        objIds=sf('DataOf',srcMachine.Id);

        if isempty(objIds)
            return;
        end


        dstMachineId=sfprivate('acquire_or_create_machine_for_model',dstBDHandle);


        LocalCopyMachineParentedData(srcMachine.Id,dstMachineId,objIds);
    catch ME
        dstMachineId=-1;
        Simulink.harness.internal.warn(ME);
    end
end


function LocalCopyMachineParentedData(srcMachineId,dstMachineId,objIds)

    assert(~isempty(objIds));

    rt=sfroot;
    clp=sfclipboard;

    srcMachine=rt.find('-isa','Stateflow.Machine','Id',srcMachineId);
    dstMachine=rt.find('-isa','Stateflow.Machine','Id',dstMachineId);

    dataObj=[];
    for i=1:length(objIds)
        dataObj=[srcMachine.find('Id',objIds(i)),dataObj];%#ok<AGROW>
    end

    clp.copy(dataObj);
    clp.pasteTo(dstMachine);




end
