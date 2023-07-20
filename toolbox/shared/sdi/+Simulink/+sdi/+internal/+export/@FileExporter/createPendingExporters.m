function this=createPendingExporters(this)
    numExporters=length(this.PendingExporters);
    for idx=1:numExporters
        fileExporter=eval(this.PendingExporters{idx});
        fileType=getFileType(fileExporter);
        if~isKey(this.CreatedExporters,fileType)
            insert(this.CreatedExporters,fileType,fileExporter);
        end
    end
    this.PendingExporters={};
end