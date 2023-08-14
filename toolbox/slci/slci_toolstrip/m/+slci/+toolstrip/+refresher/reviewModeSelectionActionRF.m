


function schema=reviewModeSelectionActionRF(cbinfo)
    schema=sl_action_schema;
    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');
    if strcmpi(ctx.getReviewMode,'AssistedReview')
        schema.icon='inspectionResult';
        schema.label=message('Slci:toolstrip:AssistedReviewModeActionText').getString();
        schema.tooltip=message('Slci:toolstrip:AssistedReviewModeActionDescription').getString();
    else
        schema.icon='inspectionReport';
        schema.label=message('Slci:toolstrip:AutomaticReviewModeActionText').getString();
        schema.tooltip=message('Slci:toolstrip:AutomaticReviewModeActionDescription').getString();
    end
end