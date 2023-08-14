function origBlockH=getOrigBlock(obj,goal)




    modelObj=goal.up;
    blockH=modelObj.slBlkH;

    blockReplacementApplied=obj.testCompAnalysisInfo.replacementInfo.replacementsApplied;
    atomicSubsystemAnalysis=sldvprivate('mdl_iscreated_for_subsystem_analysis',obj.testCompAnalysisInfo);
    origBlockH=blockH;


    if blockReplacementApplied||atomicSubsystemAnalysis
        if atomicSubsystemAnalysis
            origModelH=obj.testCompAnalysisInfo.extractedModelH;
            parentH=origModelH;
        else
            origModelH=obj.testCompAnalysisInfo.designModelH;
            parentH=origModelH;
        end

        origBlockH=sldvshareprivate('util_resolve_obj',blockH,parentH,atomicSubsystemAnalysis,...
        blockReplacementApplied,obj.testCompAnalysisInfo);

    end

end
