function r=getLinkRoot(this)


    if isempty(this.viewManager)
        r=[];
    else
        r=this.viewManager.getCurrentSettings().getDasLinkRoot();
    end
end
