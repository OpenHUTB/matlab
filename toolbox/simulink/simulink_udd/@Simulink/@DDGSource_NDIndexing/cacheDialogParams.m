function cacheDialogParams(this)




    block=this.getBlock;
    lstParams=fieldnames(block.IntrinsicDialogParameters);

    for i=1:length(lstParams)
        this.DialogData.(lstParams{i})=block.(lstParams{i});
    end

end
