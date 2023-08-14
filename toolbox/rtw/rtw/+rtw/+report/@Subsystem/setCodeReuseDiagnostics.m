function setCodeReuseDiagnostics(obj,sourceSubsystem)
    reuseDiag=get_param(obj.ModelName,'CodeReuseDiagnostics');
    if~isempty(reuseDiag)&&~isempty(sourceSubsystem)
        mappedSID=arrayfun(@(x)Simulink.ID.getSubsystemBuildSID(x.BlockSID,sourceSubsystem),reuseDiag,'UniformOutput',false);
        [reuseDiag.BlockSID]=mappedSID{:};
        for k=1:length(reuseDiag)
            if~isempty(reuseDiag(k).Blockers)
                blockers=reuseDiag(k).Blockers;
                mappedSID=arrayfun(@(x)Simulink.ID.getSubsystemBuildSID(x.SrcBlock,sourceSubsystem),blockers,'UniformOutput',false);
                [blockers.SrcBlock]=mappedSID{:};
                reuseDiag(k).Blockers=blockers;
            end
        end
    end
    obj.ReuseDiag=reuseDiag;
end
