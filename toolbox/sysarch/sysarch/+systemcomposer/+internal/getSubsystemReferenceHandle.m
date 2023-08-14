function hdl=getSubsystemReferenceHandle(instanceHdl,subRefName)






    blockSID=get_param(instanceHdl,'SID');
    blockSID=split(blockSID,':');
    blockSID=blockSID{end};
    try
        load_system(subRefName);

        originalObject=find_system(subRefName,'MatchFilter',@Simulink.match.allVariants,'SID',blockSID);
        hdl=get_param(originalObject{1},'Handle');
    catch ex
        rethrow(ex);
    end
end
