function createWorkBook(this,useXL)



    if~this.HasWorkBook
        USE_EXCEL=ispc&&useXL;
        this.WorkBook=matlab.io.spreadsheet.internal.createWorkbook('xlsx',this.FileName,USE_EXCEL);
        this.HasWorkBook=true;
    end
end
