function computeReducedBlocks(obj)





    reportInfo=rtw.report.getReportInfo(obj.ModelName);
    assert(~isempty(reportInfo));
    obj.SourceSubsystem=reportInfo.SourceSubsystem;
    if isempty(reportInfo.SourceSubsystem)
        h0=Simulink.ID.getHandle(obj.ModelName);
    else
        h0=Simulink.ID.getHandle(reportInfo.SourceSubsystem);
    end
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        allHandles=find_system(h0,'LookUnderMasks','all','FollowLinks','on','MatchFilter',@Simulink.match.activeVariants);
    else
        allHandles=find_system(h0,'LookUnderMasks','all','FollowLinks','on');
    end
    allHandles=allHandles(2:end);
    reducedHandles=setdiff(allHandles,obj.HandlesAfterCgirXforms);
    reducedSIDs=Simulink.ID.getSID(reducedHandles);
    tmpCgirReducedBlocks=setdiff(reducedSIDs,obj.SimulinkReducedBlocks);


    if~isempty(tmpCgirReducedBlocks)
        obj.CgirReducedBlocks=containers.Map(tmpCgirReducedBlocks,1:numel(tmpCgirReducedBlocks));
    end


    if~isempty(reportInfo.SourceSubsystem)
        for i=1:length(obj.SimulinkReducedBlocks)
            obj.SimulinkReducedBlocks{i}=Simulink.ID.getSubsystemBuildSID(obj.SimulinkReducedBlocks{i},reportInfo.SourceSubsystem);
        end
    end
end
