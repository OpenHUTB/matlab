function cb_HelpLinks(link)





    if strcmp(link,'supported')
        helpview(fullfile(docroot,'simulink','helptargets.map'),'root_import_dtypes');
    end

    if strcmp(link,'supportedSpreadsheet')
        helpview(fullfile(docroot,'simulink','helptargets.map'),'RIM_spreadsheet_format');
    end

    if strcmp(link,'mapping')
        helpview(fullfile(docroot,'simulink','helptargets.map'),'IMPORT_AND_MAP_WORKFLOW');
    end

    if strcmp(link,'editor_fromworkspace')
        helpview(fullfile(docroot,'simulink','helptargets.map'),'signaleditor_fromworkspace');
    end
