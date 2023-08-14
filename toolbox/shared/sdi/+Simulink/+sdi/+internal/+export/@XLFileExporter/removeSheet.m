function removeSheet(this,sheetName)



    if length(this.WorkBook.SheetNames)>1
        try
            this.WorkBook.removeSheet(sheetName);
        catch
        end
    end
end
