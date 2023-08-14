function isUpToDate=refresh(this)


    isUpToDate=true;

    if~rmidotnet.confirmSaved(this.hDoc)
        isUpToDate=false;
        return;
    end

    if~this.matchTimestamp()




        this.iSheet=rmidotnet.MSExcel.getActiveSheetInWorkbook(this.hDoc);
        this.sSheets=rmidotnet.MSExcel.getSheetNamesInWorkbook(this.hDoc);
        this.selectSheet();

        this.iParents=[];
        this.backlinks=[];
        this.namedRanges=[];
        this.cachedText=[];

        this.dTimestamp=this.getDocTime();
    end

end

