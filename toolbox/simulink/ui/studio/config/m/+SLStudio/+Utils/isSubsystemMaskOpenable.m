function res=isSubsystemMaskOpenable(block)





    res=false;
    if~(SLStudio.Utils.isSubsystemReadProtected(block)||block.isStateflow)
        block_has_open_cb=~isempty(get_param(block.handle,'OpenFcn'));
        if block.isMasked||block_has_open_cb
            res=true;
        elseif block.isConfigurableSubsystem

            obj=get_param(block.handle,'Object');
            choice=obj.getChildren;
            if~isempty(choice)
                if(hasmask(choice.Handle)||block_has_open_cb)
                    res=true;
                end
            end
        end
    end
end
