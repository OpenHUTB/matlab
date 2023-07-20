function spObj=getSpreadSheetObject(this,target)







    spObj=[];
    if(ischar(target)||target~=-1)&&~isempty(this.spreadsheetManager)
        spObj=this.spreadsheetManager.getSpreadSheetObject(target);
    end
end
