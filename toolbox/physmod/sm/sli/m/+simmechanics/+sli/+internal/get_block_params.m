function[paramNames,paramExprs,isEvals,edMode,showRtp,showDlgViz]=get_block_params(hBlock)












    maskObj=get_param(hBlock,'MaskObject');

    paramNames={maskObj.Parameters.Name};
    paramNames=paramNames(:);

    paramExprs={maskObj.Parameters.Value};
    paramExprs=paramExprs(:);

    isEvals=strcmpi({maskObj.Parameters.Evaluate},'on');
    isEvals=isEvals(:);

    paramNames{end+1}=pm_message('mech2:messages:parameters:block:position:ParamName');
    paramNames{end+1}=pm_message('mech2:messages:parameters:block:canvasPosition:ParamName');
    paramNames{end+1}=pm_message('mech2:messages:parameters:block:attributes:blockName:ParamName');

    [blkPos,canLoc]=simmechanics.sli.internal.computeBlockPosition(hBlock);

    paramExprs{end+1}=mat2str(int16(blkPos));
    paramExprs{end+1}=mat2str(canLoc);
    paramExprs{end+1}=get_param(hBlock,'Name');

    isEvals=[isEvals;true;true;false];

    edMode='Full';
    mdlH=bdroot(hBlock);
    if simmechanics.sli.internal.is_model_handle(mdlH)
        edMode=get_param(mdlH,'EditingMode');
    end



    showRtp=simmechanics.sli.internal.showRtpOptions;


    showDlgViz=simmechanics.sli.internal.blockDialogVizPref();



end

