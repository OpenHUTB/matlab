

function refreshInlineModelTool(cbinfo,action)

    if isvalid(action)
        blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
        if~isempty(blocks)
            enabled=true;
            for idx=1:numel(blocks)
                block=blocks(idx);
                [enabled,componentBlockType]=systemcomposer.internal.validator.ConversionUIValidator.canInline(block.handle);
                if isa(componentBlockType,'systemcomposer.internal.validator.Stateflow')
                    action.text=DAStudio.message('SystemArchitecture:Toolstrip:InlineBehaviorActionLabel');
                end
                if~enabled

                    break;
                end
            end
        else
            enabled=false;
        end
        action.enabled=enabled;
    end
end
