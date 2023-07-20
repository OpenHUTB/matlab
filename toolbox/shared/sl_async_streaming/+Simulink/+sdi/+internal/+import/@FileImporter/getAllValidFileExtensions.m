function validFileExtensions=getAllValidFileExtensions(this)


    numParsers=this.CustomParsers.getCount();
    validFileExtensions=cell(1,numParsers);
    for idx=1:numParsers
        validFileExtensions{idx}=this.CustomParsers.getKeyByIndex(idx);
    end


    this.createPendingParsers();
    numParsers=this.CreatedParsers.getCount();
    for idx=1:numParsers
        fileParser=this.CreatedParsers.getDataByIndex(idx);
        validFileExtensions=[validFileExtensions,fileParser.getFileExtension()];%#ok
    end


    validFileExtensions=unique(validFileExtensions);
end