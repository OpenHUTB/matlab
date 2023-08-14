function removeAllSheetsExcept(this,runName)



    sheetsToRemove={};
    for sheetIdx=1:length(this.WorkBook.SheetNames)
        if this.WorkBook.SheetNames(sheetIdx)~=runName
            sheetsToRemove{end+1}=this.WorkBook.SheetNames(sheetIdx);%#ok
        end
    end
    for sheetIdx=1:length(sheetsToRemove)
        this.WorkBook.removeSheet(char(sheetsToRemove{sheetIdx}));
    end
end
