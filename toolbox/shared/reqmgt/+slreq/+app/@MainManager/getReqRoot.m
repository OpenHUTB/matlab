function r=getReqRoot(this)



    if isempty(this.viewManager)
        r=[];
    else
        r=this.viewManager.getCurrentSettings().getDasReqRoot();
    end
end
