function unhilite(this,dlg,forceRefresh)




    block=this.getBlock;









    if isfield(block.UserData,'BlockHandles')
        blockHandles=block.UserData.BlockHandles;
    else
        blockHandles=[];
    end

    if forceRefresh
        this.refresh(dlg,true);
    end

    try
        hiliting=get_param(blockHandles,'HiliteAncestors');
        index=strncmp(hiliting,'find',4);
        for i=1:length(index)
            if index(i)
                set_param(blockHandles(i),'HiliteAncestors','none');
            end
        end
    catch %#ok<CTCH>


        this.unhilite(dlg,true);
    end

end

