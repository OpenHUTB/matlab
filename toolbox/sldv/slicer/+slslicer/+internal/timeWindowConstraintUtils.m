


classdef timeWindowConstraintUtils




    properties
    end

    methods(Static)
        function yesno=isSupported(modelObj,cvd)

            if isa(modelObj,'Stateflow.Object')&&...
                isCommentedOut(modelObj)
                yesno=false;
                return;
            end

            mdlObj=getModelObjForCov(modelObj);
            if isempty(mdlObj)
                yesno=false;
            else
                [~,detail]=getCoverageInfo(cvd,mdlObj,'decision');
                yesno=~isempty(detail)&&isfield(detail,'decision');
            end
        end

        function covConstraintStruct=getConstraintStruct(modelObj,cvd)
            covConstraintStruct=[];
            mdlObj=getModelObjForCov(modelObj);

            [~,detail]=getCoverageInfo(cvd,mdlObj,'decision');
            [idx,outIdx]=getDecisionOutcomeIdx(modelObj,detail);

            if~isempty(detail)&&isfield(detail,'decision')&&...
                ~isempty(idx)&&~isempty(outIdx)

                covIds=cvd.getCovIdx(mdlObj,'decision');
                decId=covIds(idx);
                covConstraintStruct=struct('decNum',idx,...
                'decId',decId,...
                'outcomeNum',outIdx-1);
            end
        end

        function executioncount=getExecutionCounts(modelObj,cvd)
            mdlObj=getModelObjForCov(modelObj);
            executioncount=0;
            if~isempty(mdlObj)
                [~,detail]=Coverage.CovData.getCovInfo(cvd,mdlObj,'decision');
                [idx,outIdx]=getDecisionOutcomeIdx(modelObj,detail);
                if~isempty(idx)
                    executioncount=detail.decision(idx).outcome(outIdx).executionCount;
                end
            end
        end
    end

end


function[decIdx,outIdx]=getDecisionOutcomeIdx(modelObj,detail)
    decIdx=[];
    outIdx=[];
    if~isempty(detail)&&isfield(detail,'decision')
        if~isa(modelObj,'Stateflow.Transition')
            execMetric=getString(message...
            ('Slvnv:simcoverage:make_formatters:MSG_SF_ACTIVE_CHILD_CALL_S'));
            decIdx=Coverage.CovData.getDecStructIdx(detail,execMetric);
        else
            decIdx=1;
        end
        outcome=detail.decision(decIdx).outcome;
        if~isa(modelObj,'Stateflow.Transition')
            stateName=modelObj.Name;
            outIdx=find(arrayfun(@(o)strcmp(o.text,['"',stateName,'"']),outcome));
        else

            outIdx=2;
        end
    end

end

function mdlObj=getModelObjForCov(selectedHandle)








    mdlObj=[];
    if isa(selectedHandle,'Stateflow.State')||isa(selectedHandle,'Stateflow.AtomicSubchart')
        parentObj=selectedHandle.getParent;
        while isa(parentObj,'Stateflow.Box')
            parentObj=parentObj.getParent;
        end
        if isa(parentObj,'Stateflow.Chart')||isa(parentObj,'Stateflow.StateTransitionTableChart')
            mdlObj=parentObj;
        else
            mdlObj={parentObj.Chart.Path,parentObj};
        end
    elseif isa(selectedHandle,'Stateflow.Transition')
        mdlObj={selectedHandle.Chart.Path,selectedHandle};
    else
        return;
    end
end


function yesno=isCommentedOut(obj)
    try
        yesno=obj.IsExplicitlyCommented||obj.IsImplicitlyCommented;
    catch mex
        yesno=false;
    end
end