function doExport(exportType,cbinfo)




    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;

    isDictExportable=~guiObj.isDictEmpty();
    if isDictExportable
        switch exportType
        case 'M'
            guiObj.exportToM();
        case 'MAT'
            guiObj.exportToMAT();
        case 'ARXML'
            guiObj.exportPlatform();
        case 'Generic'

            switch guiObj.SelectedPlatformId
            case 'Native'

            case 'AUTOSARClassic'
                guiObj.exportPlatform();
            otherwise
                assert(false,'Unexpected platform id for export accelerator.')
            end
        otherwise
            assert(false,'Unexpected export type from callback.')
        end
    else

        dictObj=guiObj.getInterfaceDictObj();
        dp=DAStudio.DialogProvider;
        title=DAStudio.message('Simulink:utility:ErrorDialogSeverityError');
        errMsg=DAStudio.message('interface_dictionary:common:CannotExportEmptyDictionary',dictObj.filepath);
        dp.errordlg(errMsg,title,true);
    end
end
