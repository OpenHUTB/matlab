function out=ignoreObjectiveForValidation(obj,objIdx)
    out=false;
    modelObjectIndex=obj.sldvData.Objectives(objIdx).modelObjectIdx;
    analysisInfo=obj.sldvData.AnalysisInformation;

    if~isfield(analysisInfo,'ReplacementInfo')
        out=false;
        return;
    else
        replacementInfo=analysisInfo.ReplacementInfo;
    end

    for i=1:length(replacementInfo)
        modelObjectsInReplacementInfo=replacementInfo(i).modelObjects;
        for j=1:length(modelObjectsInReplacementInfo)
            if modelObjectIndex==modelObjectsInReplacementInfo(j)&&...
                ~strcmp(replacementInfo(i).RepRuleInfo.BlockType,'ModelReference')
                out=true;
                return;
            end
        end
    end
end