
function plotResultsInSDI(expr,plotSubExpr,isContinuous,runId)

    if(isa(expr,'sltest.assessments.Expression'))
        expr=expr.internal;
    end

    if~(isa(expr,'sltest.assessments.internal.expression'))
        error(message('sltest:assessments:ExpectedArgumentType',1,'an expression'));
    end

    if nargin<2
        plotSubExpr=false;
    end

    if nargin<3
        isContinuous=true;
    end





    try
        r=expr.results(plotSubExpr);
    catch me
        disp(me);
    end
    if(nargin<4)
        runID=Simulink.sdi.createRun('Expression Evaluator');
    else
        runID=runId;
    end
    parentMap=containers.Map;
    signalMap=containers.Map;
    sdiEngine=Simulink.sdi.Instance.engine;
    for i=1:numel(r)
        v=r(i).Value;
        addVerifyMetaData=false;
        if strcmp(r(i).Name,expr.stringLabel())&&~isempty(v)&&isa(v(1),'sltest.assessments.Logical')
            v=arrayfun(@LogicalToSlTestResult,v);
            addVerifyMetaData=true;
        end
        ts=timeseries(v,r(i).Time);
        ts.Name=r(i).Name;

        ts.DataInfo.Interpolation=tsdata.interpolation.createZOH;
        sigID=Simulink.sdi.addToRun(runID,'namevalue',{r(i).Name},{ts});
        signalMap(r(i).Name)=sigID;
        if(isfield(r(i),'Children'))
            if(~isempty(r(i).Children))
                sdiEngine.setMetaDataV2(sigID,'ExpressionHasChildren',int32(1));
            end
            for k=1:numel(r(i).Children)
                parentMap(r(i).Children{k})=sigID;
            end
        end
        if addVerifyMetaData

            if(strcmpi(expr.stringLabel,r(i).Name))
                sdiEngine.setMetaDataV2(sigID,'IsAssessment',int32(1));

                if~isempty(v)
                    outcome=v(1);
                    if(numel(v)>1&&v(2)>outcome)
                        outcome=v(2);
                    end
                    if(numel(v)>2&&v(3)>outcome)
                        outcome=v(3);
                    end
                end
                sdiEngine.setMetaDataV2(sigID,'AssessmentResult',int32(outcome));
            end
            if(~isContinuous)
                sdiEngine.sigRepository.setSignalIsEventBased(sigID,true);
            end
        end
    end
    sNames=parentMap.keys;
    sIds=parentMap.values;
    for k=1:numel(sNames)
        sdiEngine.setMetaDataV2(signalMap(sNames{k}),'ParentExpressionID',sIds{k});
    end
end

function y=LogicalToSlTestResult(u)
    switch u
    case sltest.assessments.Logical.True
        y=slTestResult.Pass;
    case sltest.assessments.Logical.False
        y=slTestResult.Fail;
    case sltest.assessments.Logical.Untested
        y=slTestResult.Untested;
    end
end

