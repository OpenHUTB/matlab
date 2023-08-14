function userRange=updateImportTable(blockH)






    userRange='';

    if~ishandle(blockH)
        return;
    end

    dlgHandle=iofile.FromSpreadsheetBlockUI.util.getDialogFromBlockHandle(blockH);


    userRange=get_param(blockH,'Range');

    if isempty(dlgHandle)

        return;
    end

    dlgSrc=dlgHandle.getSource();
    client=iofile.FromSpreadsheetBlockUI.util.getClientInstance(blockH);

    if isempty(client)
        return;
    end


    fileName=get_param(dlgSrc,'FileName');
    [path,~,~]=fileparts(fileName);

    if isempty(path)

        fileName=which(fileName);
    end
    blockFileName=fileName;


    clientFileName=iofile.FromSpreadsheetBlockUI.util.getClientFileName(blockH);

    if strcmp(clientFileName,blockFileName)



        blockSheetName=get_param(dlgSrc,'SheetName');
        clientSheetName=client.getCurrentSheetName;


        blockRange=userRange;


        if strcmp(clientSheetName,blockSheetName)

            userRange=client.setSelection(blockRange);
        else

            try

                client.setCurrentSheetName(blockSheetName);

                userRange=client.setSelection(blockRange);
            catch
                errorMessage=DAStudio.message('sl_iofile:excelfile:sheetNotFound',blockSheetName);
                errorTitle=DAStudio.message('sl_iofile:excelfile:errorTitle');
                errordlg(errorMessage,errorTitle);
            end

        end
    else

        iofile.FromSpreadsheetBlockUI.closeImportTableFromBlock(client);
        iofile.FromSpreadsheetBlockUI.cb_LaunchRangeSelector(dlgHandle);
        return;
    end

end

