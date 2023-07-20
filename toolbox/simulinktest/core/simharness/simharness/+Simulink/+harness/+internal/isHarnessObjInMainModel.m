function res=isHarnessObjInMainModel(harnessInfo,harnessObjHandle)




    if isempty(harnessInfo)||~isstruct(harnessInfo)||~harnessInfo.isOpen||...
        harnessInfo.synchronizationMode~=2
        res=true;
        return;
    end




    res=false;
    harnessObjSID=get_param(harnessObjHandle,'SID');


    if strcmp(harnessObjSID,'1')
        res=Simulink.harness.check(harnessInfo.ownerFullPath,harnessInfo.name);
        return;
    end



    try
        fixedSID=strrep(harnessObjSID,'1:','');


        matchingObj=find_system(harnessInfo.ownerFullPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID',fixedSID);
        if~isempty(matchingObj)
            matchingObjHandle=get_param(matchingObj{:},'Handle');
            harnessObjChecksum=Simulink.harness.internal.getBlockChecksum(harnessObjHandle);
            matchingObjChecksum=Simulink.harness.internal.getBlockChecksum(matchingObjHandle);
            if isequal(harnessObjChecksum,matchingObjChecksum)
                res=true;
                return;
            end
        end
    catch

    end
end
