function setRangeFromImportTable(blockH,varargin)






    dlgHandle=iofile.FromSpreadsheetBlockUI.util.getDialogFromBlockHandle(blockH);

    if isempty(dlgHandle)

        return;
    end

    dlgSrc=dlgHandle.getSource();

    eventData=varargin{1};


    excelRange=eventData.selection;
    charExcelRange=char(excelRange);


    sheetName=eventData.sheetName;
    charSheetName=char(sheetName);

    if isempty(dlgHandle)

        set_param(dlgSrc,'SheetName',charSheetName);
        set_param(dlgSrc,'Range',charExcelRange);

    else

        imd=DAStudio.imDialog.getIMWidgets(dlgHandle);
        tag='Sheet name:';
        sheetNameWidget=imd.find('Tag',tag);
        blkSheet=sheetNameWidget.text;
        if~strcmp(blkSheet,charSheetName)
            sheetNameWidget.text=charSheetName;
        end

        tag='Range:';
        rangeWidget=imd.find('Tag',tag);
        blkRange=rangeWidget.text;
        if~strcmp(blkRange,charExcelRange)
            rangeWidget.text=charExcelRange;
        end
    end
end

