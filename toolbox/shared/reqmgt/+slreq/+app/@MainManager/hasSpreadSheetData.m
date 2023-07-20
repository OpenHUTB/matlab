function out=hasSpreadSheetData(this)



    out=~isempty(this.spreadsheetManager)&&this.spreadsheetManager.hasData();
end

