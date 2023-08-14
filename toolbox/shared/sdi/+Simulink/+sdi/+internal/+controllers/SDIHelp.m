function SDIHelp(helpType)
    try
        interface=Simulink.sdi.internal.Framework.getFramework();
        mapFileName=getHelpMapFile(interface);
        switch helpType
        case 'sdiHelp'
            helpview(mapFileName,'simulation_data_inspector');
        case 'programmaticInterface'
            helpview(mapFileName,'simulation_data_inspector_api');
        case 'aboutSimulink'
            launchHelpAbout(interface);
        case 'comparisonOptionsHelp'
            helpview(mapFileName,'sdi_comparison_options_dialog');
        case 'exportSignalRunsHelp'
            helpview(mapFileName,'sdi_export_data_dialog');
        case 'sdiStreamData'
            helpview(mapFileName,'sdi_log_data');
        case 'importDataHelp'
            helpview(mapFileName,'sdi_import_data_dialog');
        case 'importDataFormats'
            helpview(mapFileName,'sdi_import_format');
        case 'importDataFormatCSV'
            helpview(mapFileName,'sdi_import_csv');
        case 'sdiPrefsHelpAll'
            helpview(mapFileName,'sdi_prefsHelp_All');
        case 'storageConfigHelp'
            helpview(mapFileName,'sdi_prefsHelp_Storage');
        case 'recordModeDetailHelp'
            helpview(mapFileName,'sdi_prefsHelp_Storage_Details');
        case 'runConfigHelp'
            helpview(mapFileName,'sdi_prefsHelp_NewRun');
        case 'inspectTableColumns'
            helpview(mapFileName,'sdi_prefsHelp_Inspect_TableColumns');
        case 'inspectTableSelection'
            helpview(mapFileName,'sdi_prefsHelp_Selection');
        case 'compareTableColumns'
            helpview(mapFileName,'sdi_prefsHelp_Compare_TableColumns');
        case 'compareAlignment'
            helpview(mapFileName,'sdi_prefsHelp_Alignment');
        case 'compareSignalColors'
            helpview(mapFileName,'sdi_prefsHelp_Colors');
        case 'groupSignalsHelp'
            helpview(mapFileName,'sdi_prefsHelp_Group');
        case 'reportHelp'
            helpview(mapFileName,'sdi_generate_report_dialog');
        case 'sdiSaveLoadSession'
            helpview(mapFileName,'sdi_prefsHelp_Save');
        case 'sdiArchive'
            helpview(mapFileName,'sdi_prefsHelp_Archive');
        case 'pctHelp'
            helpview(mapFileName,'sdi_prefsHelp_Parallel');
        case 'pctSupport'
            tag=interface.getPCTHelpAnchor();
            helpview(mapFileName,tag);
        case 'unitsHelp'
            helpview(mapFileName,'sdi_prefsHelp_Units');
        case 'sdiMetaDataMismatchHelp'
            helpview(mapFileName,'sdi_compareRuns');
        case 'sdiCompareAlignHelp'
            helpview(mapFileName,'sdi_compare_align');
        case 'sdiCompareSyncHelp'
            helpview(mapFileName,'sdi_compare_sync');
        case 'sdiCompareLimitationHelp'
            helpview(mapFileName,'sdi_compare_limitations');
        otherwise
            helpview(mapFileName,'simulation_data_inspector');
        end
    catch me %#ok<NASGU>
        msgStr=getString(message('SDI:sdi:HelpErrorMsg'));
        titleStr=getString(message('SDI:sdi:HelpErrorTitle'));
        okStr=getString(message('SDI:sdi:OKShortcut'));

        Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
        'sdi',...
        titleStr,...
        msgStr,...
        {okStr},...
        0,...
        -1,...
        []);
    end
end
