function findSrc(this,dlg)





    sig=this.getSelectedSignalString();

    this.unhilite(dlg,false);

    if~isempty(sig)
        block=this.getBlock;





        if~isfield(block.UserData,'busStruct')
            busStruct=block.BusStruct;
        else
            busStruct=block.UserData.busStruct;
        end


        if~block.isHierarchyReadonly
            block.UserData.busStruct=busStruct;
            block.UserData.BlockHandles=getBlockHandles(this,busStruct);
        end



        for i=1:length(sig)
            sigSrc=findBusSrc(this,busStruct,sig{i});

            if~isempty(sigSrc)&&sigSrc.Handle~=block.Handle
                found=~strcmp(get_param(sigSrc.Handle,'HiliteAncestors'),'find');
                if found
                    hilite_system(sigSrc.Handle,'find');
                end
            end
        end
    end
end
