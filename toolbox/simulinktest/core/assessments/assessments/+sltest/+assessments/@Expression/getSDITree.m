


function tree=getSDITree(expr,quantitative)
    if(nargin<2)
        expr.syncWithSDI();
        quantitative=false;
    else
        expr.syncWithSDI(quantitative);
    end
    if isa(expr,'sltest.assessments.Alias')

        expr.CollapseUnaryChain=false;
    end

    idx=-1;
    function node=apply(expr,~)
        node.id=idx;
        idx=idx+1;
        node.label=expr.internal.stringLabel();
        node.signalID=expr.internal.metadata.sdiSignalID;
        node.isenum=expr.internal.metadata.sdiIsEnum;
    end
    tree=expr.transform(@apply);
    tree.signalID=expr.internal.metadata.sdiAssessmentID;


    if expr.internal.hasMetadata('sdiAssessmentResult')
        tree.isenum=true;
        tree.assessmentResult=int32(expr.internal.metadata.sdiAssessmentResult);
    end
    if(quantitative)
        tree.robustness=min(expr.internal.results.Value);
    end
end
