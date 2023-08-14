function[success,message,modifiedObjects]=merge(mergeActionData)























    success=true;
    modifiedObjects=java.util.ArrayList;



    node=mergeActionData.getFromNode();
    if isempty(node)
        node=mergeActionData.getToNode();
    end
    type=char(node.getTagName());
    isSimulink=i_IsSimulink(type,node);




    dstNodePath=char(mergeActionData.getToNode().getNodePath());
    if isSimulink&&strcmp(type,'chart')&&strcmp(mergeActionData.getActionName(),'Parameter')
        isSimulink=slxmlcomp.internal.stateflow.chart.isSimulinkChartParameter(...
        dstNodePath,char(mergeActionData.getParameterName()));
    end

    ensureModelsAreLoaded(mergeActionData);

    try
        if isSimulink
            [modifiedObjects,message]=slxmlcomp.internal.merge.mergeSimulink(type,mergeActionData);
        else
            [modifiedObjects,message]=slxmlcomp.internal.merge.mergeStateflow(type,mergeActionData);
        end
    catch E
        success=false;
        message=E.message;
    end
end







function result=i_IsSimulink(type,node)
    import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.type.chart.ChartUtils;
    if ChartUtils.isSubChart(node)
        result=false;
        return
    end

    switch type
    case{'state','transition','junction','eml','data','event','message'}

        result=false;
    case{'activeStateOutput','props','array','type','fixpt','range','unit'}

        result=false;
    otherwise
        result=true;
    end
end

function ensureModelsAreLoaded(jMergeActionData)
    import slxmlcomp.internal.highlight.window.BDInfo
    sourceBDInfo=BDInfo.fromMergeActionDataSource(jMergeActionData);
    sourceBDInfo.ensureLoaded();
    targetBDInfo=BDInfo.fromMergeActionDataTarget(jMergeActionData);
    targetBDInfo.ensureLoaded();
end
