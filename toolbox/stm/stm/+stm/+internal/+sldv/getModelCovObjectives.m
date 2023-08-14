
function settings=getModelCovObjectives(modelCovObjectives)
    settings='';
    if modelCovObjectives=="Decision"
        settings='d';
    elseif modelCovObjectives=="ConditionDecision"
        settings='cd';
    elseif modelCovObjectives=="MCDC"||modelCovObjectives=="EnhancedMCDC"
        settings='m';
    end
end
