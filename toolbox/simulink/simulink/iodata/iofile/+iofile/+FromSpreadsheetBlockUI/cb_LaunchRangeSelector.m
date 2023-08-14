function cb_LaunchRangeSelector(dlgHandle,~)





    dlgSrc=dlgHandle.getSource();
    blockH=get_param(dlgSrc,'handle');

    fileName=get_param(dlgSrc,'FileName');


    if exist(fileName,'file')~=2
        ex=message('sl_iofile:excelfile:notFound',fileName);
        blockFileName=get_param(blockH,'FileName');
        if~strcmp(blockFileName,fileName)&&dlgHandle.hasUnappliedChanges

            suggestion=message('sl_iofile:excelfile:applyChangesSuggestion');
            action=MSLDiagnostic([],suggestion).action;
            msg=MSLException(blockH,ex,'ACTION',action);
        else


            msg=MSLException(blockH,ex);
        end
        sldiagviewer.reportError(msg);
        return;
    end

    [path,~,~]=fileparts(fileName);

    if isempty(path)

        fileName=which(fileName);
    end

    fileInfo=xlsfinfo(fileName);

    if isempty(fileInfo)


        errorMsg=getString(message('sl_iofile:excelfile:invalidFile',fileName));
        errorID='sl_iofile:excelfile:invalidFile';
        sldiagviewer.reportError(errorMsg,'MessageId',errorID,'Component','Simulink','Category','Block');
        return;
    end


    titleUnique=iofile.FromSpreadsheetBlockUI.util.getTitleFromBlockHandle(blockH);
    titleUI=message('sl_iofile:excelfile:RangeSelectionUITitle').getString;
    title=[titleUI,' - ',titleUnique];


    id=['SpreadsheetImportClient',num2str(blockH,32)];


    range=get_param(blockH,'range');


    sheetName=get_param(blockH,'SheetName');

    clientH=internal.matlab.importtool.peer.UIImporter(fileName,...
    "ImportType","spreadsheet",...
    "AppName",id,...
    "SelectionChangedFcn",@(eventData)iofile.FromSpreadsheetBlockUI.setRangeFromImportTable(blockH,eventData),...
    "WindowClosedFcn",@(varargin)iofile.FromSpreadsheetBlockUI.closeImportTable(blockH),...
    "Title",title,...
    "InitialSelection",range,...
    "InitialSheet",sheetName,...
    "InteractionMode","rangeOnly");


    iofile.FromSpreadsheetBlockUI.util.attachCallbacks(blockH,clientH);


    listenerMap=iofile.FromSpreadsheetBlockUI.ListenerMap.getInstance();
    listenerMap.addListener(num2str(blockH,32),handle.listener(dlgHandle,'ObjectBeingDestroyed',...
    @(src,dst)iofile.FromSpreadsheetBlockUI.closeImportTableFromBlock(clientH)));


    clientMap=iofile.FromSpreadsheetBlockUI.ClientMap.getInstance();
    clientMap.addClient(num2str(blockH,32),clientH);
    clientMap.addClientFileName(num2str(blockH,32),fileName);
end
