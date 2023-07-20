


function schema=variantTransitionRF(userdata,cbinfo)
    if isvalid(cbinfo)
        schema=sl_toggle_schema;
        schema.state='Disabled';
        schema.checked='UnChecked';
        selection=cbinfo.selection;
        if selection.size==1
            transH=selection.at(1);
            if~isa(transH,'StateflowDI.Transition')||~transH.isvalid||...
                ~Stateflow.internal.transitionHasIsVariantProperty(transH.backendId)
                schema.state='Hidden';
                return;
            end
            schema.state='Enabled';
            if transH.isVariant
                schema.checked='Checked';
            end
        end
        schema.callback=@SFStudio.internal.variantTransitionCB;
    end
end
