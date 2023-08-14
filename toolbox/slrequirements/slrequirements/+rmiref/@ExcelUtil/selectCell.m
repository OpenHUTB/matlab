function hRange=selectCell(~,hDoc,locationStr)




    hSheets=hDoc.sheets;
    hSheet=hDoc.ActiveSheet;
    switch(locationStr(1))
    case '$'

        try
            [target_sheet,location]=rmiref.ExcelUtil.locationToSheetName(locationStr(2:end));
            if~isempty(target_sheet)&&~strcmp(target_sheet,hSheet.Name)
                hSheet=hSheets.Item(target_sheet);
                hSheet.Activate;
            end
            hRange=hSheet.Range(location);
        catch
            hRange=[];
            return;
        end

    case '@'

        try
            hName=hDoc.Names.Item(locationStr(2:end));

            target_sheet=rmiref.ExcelUtil.itemToSheetName(hName);
            if~isempty(target_sheet)&&~strcmp(target_sheet,hSheet.Name)
                hSheet=hSheets.Item(target_sheet);
                hSheet.Activate;
            end
            hRange=hName.RefersToRange;
        catch
            hRange=[];
            return;
        end

    case '?'

        [target_sheet,location]=rmiref.ExcelUtil.locationToSheetName(locationStr(2:end));
        if~isempty(target_sheet)&&~strcmp(target_sheet,hSheet.Name)
            hSheet=hSheets.Item(target_sheet);
            hSheet.Activate;
        end
        hAll=hSheet.Range('A1:IV20000');
        hRange=hAll.Find(location);

    otherwise
        hAll=hSheet.Range('A1:IV20000');
        hRange=hAll.Find(locationStr);
    end

    if~isempty(hRange)
        hRange.Select;
    end
end
