function createPendingParsers(this)
    numParsers=length(this.PendingParsers);
    for idx=1:numParsers
        if~isKey(this.CreatedParsers,this.PendingParsers{idx})
            varParser=eval(this.PendingParsers{idx});
            varParser.WorkspaceParser=this;
            insert(this.CreatedParsers,this.PendingParsers{idx},varParser);
        end
    end
    this.PendingParsers={};
end
