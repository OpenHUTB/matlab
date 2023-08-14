

function restoreDefaultPortPlacementRF(cbinfo,action)










    try
        enabled=false;

        if cbinfo.selection.size==1
            selectedBlock=cbinfo.selection.at(1);
            if isa(selectedBlock,'SLM3I.Block')
                blkH=selectedBlock.handle;
                hasDefaultPortPlacement=isempty(get_param(blkH,'PortSchema'));
                enabled=~hasDefaultPortPlacement;
            end
        end

        action.enabled=enabled;
    catch ex
        return;
    end

end


