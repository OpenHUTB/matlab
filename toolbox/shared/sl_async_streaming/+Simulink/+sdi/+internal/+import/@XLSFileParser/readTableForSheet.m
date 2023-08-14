function[ret,types]=readTableForSheet(this,sheetName,sheetIdx)
    types=this.CachedTableTypes(sheetName);
    if this.CachedTableData.isKey(sheetName)
        ret=this.CachedTableData(sheetName);

        rowsToRemove=all(types==this.TypeIDs.EMPTY,2);
        ret(rowsToRemove==1,:)=[];
        types(rowsToRemove==1,:)=[];
    else
        sheet=this.WorkBook.getSheet(sheetIdx);
        range=sheet.usedRange();
        sheetData=sheet.read(range);
        [ret,types]=this.removeEmptyCols(sheetData,types);
        this.CachedTableData(sheetName)=ret;
    end
    this.CachedTableTypes(sheetName)=types;
end
