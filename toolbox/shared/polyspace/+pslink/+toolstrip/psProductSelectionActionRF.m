function schema=psProductSelectionActionRF(callbackInfo)






    schema=sl_action_schema;
    opts=pslinkoptions(callbackInfo.model.Handle);
    if strcmpi(opts.VerificationMode,'CodeProver')
        schema.icon='goalProvePolyspace';
        schema.label=message('polyspace:toolstrip:ModePolyspaceCodeProverText').getString();
        schema.tooltip=message('polyspace:toolstrip:ModePolyspaceCodeProverDescription').getString();
    else
        schema.icon='goalBugsPolyspace';
        schema.label=message('polyspace:toolstrip:ModePolyspaceBugFinderText').getString();
        schema.tooltip=message('polyspace:toolstrip:ModePolyspaceBugFinderDescription').getString();
    end

