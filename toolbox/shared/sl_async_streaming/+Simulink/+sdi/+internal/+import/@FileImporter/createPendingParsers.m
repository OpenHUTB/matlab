function this=createPendingParsers(this)
    numParsers=length(this.PendingParsers);
    for idx=1:numParsers
        if~isKey(this.CreatedParsers,this.PendingParsers{idx})
            fileParser=eval(this.PendingParsers{idx});
            if length(fileParser.getFileExtension())==1
                ext=fileParser.getFileExtension();
                insert(this.CreatedParsers,lower(ext{1}),fileParser);
            elseif length(fileParser.getFileExtension())>1
                allExtensions=fileParser.getFileExtension();
                for extId=1:length(allExtensions)
                    curExt=allExtensions{extId};
                    insert(this.CreatedParsers,lower(curExt),fileParser);
                end
            end
        end
    end
    this.PendingParsers={};
end