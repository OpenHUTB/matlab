

function refreshLinkToModelTool(cbinfo,action)

    if isvalid(action)
        blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
        if~isempty(blocks)
            enabled=true;
            for idx=1:numel(blocks)
                block=blocks(idx);
                if(SLStudio.Utils.objectIsValidBlock(block))
                    enabled=systemcomposer.internal.validator.ConversionUIValidator.canLinkToModel(block.handle);
                else
                    enabled=false;
                end
            end
        else
            enabled=false;
        end
        action.enabled=enabled;
    end
end
