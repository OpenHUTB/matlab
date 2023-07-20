function showCoverageFilterViewerCB(cbinfo)

    sel=cbinfo.getSelection;
    if isempty(sel)
        sel=cbinfo.uiObject;
    end
    if numel(sel)~=1
        return
    end

    if isa(sel,'Stateflow.Object')
        if isa(sel,'Stateflow.Chart')||isa(sel,'Stateflow.StateTransitionTableChart')||isa(sel,'Stateflow.ReactiveTestingTableChart')||isa(sel,'Stateflow.TruthTableChart')
            chId=sel.Id;
        else
            chId=sel.Chart.Id;
        end
        instanceH=sf('get',chId,'.activeInstance');
        if instanceH==0
            instanceH=sfprivate('chart2block',chId);
        end
        modelH=bdroot(instanceH);
        modelObj=get_param(modelH,'object');
    else
        modelObj=cbinfo.model;
    end

    [~,topModelName]=SlCov.FilterEditor.isCoverageEnabled(cbinfo.studio);

    if~isempty(modelObj)
        filterObj=cvi.TopModelCov.getFilterObj(topModelName);
        cvi.TopModelCov.showFilterEditor(filterObj);
    end
end