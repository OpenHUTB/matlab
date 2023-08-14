function BrowseSource(hThis,dlg)








    dlgEntry=dlg.getWidgetValue('ComponentName');
    dlgEntryPath=which(dlgEntry);
    dlgEntryPathDir=fileparts(dlgEntryPath);
    if~isempty(dlgEntryPath)&&exist(dlgEntryPathDir,'dir')
        currentPath=dlgEntryPathDir;
    elseif exist(dlgEntry,'dir')
        currentPath=dlgEntry;
    elseif exist(dlgEntry,'file')
        dlgEntryDir=fileparts(dlgEntry);
        currentPath=dlgEntryDir;
    else
        currentPath='';
    end


    browseTitle=getString(message('physmod:ne_sli:dialog:BrowseSourceDialogTitle'));
    [theFile,selectedPath]=uigetfile({'*.ssc;*.sscp;'},browseTitle,currentPath);


    if ischar(theFile)

        theSelection=fullfile(selectedPath,theFile);
        nesl_getfunctioninfo=nesl_private('nesl_getfunctioninfo');
        info=nesl_getfunctioninfo(theSelection);


        nesl_promptifaddpathneeded=nesl_private('nesl_promptifaddpathneeded');
        info=nesl_promptifaddpathneeded(info);


        nesl_resolvefunctioninfo=nesl_private('nesl_resolvefunctioninfo');
        [result,msg]=nesl_resolvefunctioninfo(info);
        if isempty(result)
            browseTitle=getString(message('physmod:ne_sli:dialog:ErrorWhileLoadingComponent'));
            errordlg(msg,browseTitle,'modal');
            compToSet=fullfile(selectedPath,theFile);
        else
            compToSet=result;
        end

        hThis.ComponentName=compToSet;


        if~strcmp(dlgEntry,compToSet)
            dlg.setWidgetValue('ComponentName',compToSet);
        end
    end

end
