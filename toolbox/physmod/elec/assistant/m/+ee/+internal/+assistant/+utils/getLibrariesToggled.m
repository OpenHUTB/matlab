function librariesToggled=getLibrariesToggled()





    blockImportPath=fullfile(ee.internal.assistant.utils.getAssistantRoot,'transform');


    modelFiles=dir(fullfile(blockImportPath,'','*.slx'));
    modelFiles={modelFiles(:).name}';


    elecImportPrefix='elec_conv';
    librariesToggled=modelFiles(~strncmpi(modelFiles,elecImportPrefix,length(elecImportPrefix)));


    librariesToggled=regexprep(librariesToggled,'\.slx$','');

end

