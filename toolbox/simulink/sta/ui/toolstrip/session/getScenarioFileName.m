function fullFileLocationToWrite=getScenarioFileName(appInstanceID)



    currentSupportedFileExtension='.mldatx';


    subChannel='sta/mainui/diagnostic/request';
    fullChannel=sprintf('/sta%s/%s',appInstanceID,subChannel);


    fullFileLocationToWrite='';


    [filename,pathname]=uiputfile(...
    {['*',currentSupportedFileExtension],getString(message('sl_sta:sta:SessionFiles'));},...
    getString(message('sl_sta:sta:DialogTitleSaveAs')));




    if ischar(filename)&&~isempty(filename)

        [~,~,ext]=fileparts(filename);

        if strcmpi(ext,currentSupportedFileExtension)

            fullFileLocationToWrite=fullfile(pathname,filename);
        else

            slwebwidgets.errordlgweb(fullChannel,...
            'sl_sta_general:common:Error',...
            getString(message('sl_sta:sta:ScenarioExtensionBad',currentSupportedFileExtension)));

        end

    end