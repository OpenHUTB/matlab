function CloseCallback(this,dlg)




    block=this.getBlock;
    if(~isempty(block.parent))
        if~block.isHierarchyReadonly
            this.unhilite(dlg,false);

            block.UserData=block.UserData.oldUserData;
        end
    end

    this.closeCallback(dlg);
end
