function apps=getInstalledApplications(this)










    if~this.isConnected()
        this.connect();
    end

    try
        res=this.executeCommand(['ls ',this.appsDirOnTarget]);
    catch
        apps=[];
        return;
    end
    apps=split(res.Output);
    idxs=cellfun(@(x)~isempty(x),apps);
    if isempty(idxs)
        apps=[];
    else
        apps=apps(idxs);
    end
end
