function gatherAndSetResults(this,results,checkObj,mdladvObj)
    if isempty(results)
        mdladvObj.setCheckResultStatus(true);
        checkObj.setResultDetails(Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_tip']),...
        'Status',DAStudio.message([this.CheckCatalogPrefix,this.GuidelineID,'_pass'])));
        mdladvObj.setActionEnable(false);
    elseif isa(results,'ModelAdvisor.ResultDetail')
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(true);
        checkObj.setResultDetails(results);
    else
        error('Invalid results found');
    end
end