function writeCompositionFile(modelName,fileName,includeComponents)






    argParser=inputParser;
    argParser.addRequired('ModelName',@ischar);
    argParser.addRequired('FileName',@ischar);
    argParser.parse(modelName,fileName);

    [~,modelName]=fileparts(argParser.Results.ModelName);
    fileName=argParser.Results.FileName;
    m3iModel=autosar.api.Utils.m3iModel(modelName);
    schemaVer=get_param(modelName,'AutosarSchemaVersion');


    exporter=autosar.mm.arxml.Exporter(m3iModel,schemaVer);
    maxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
    exporter.setMaxShortNameLength(maxShortNameLength);



    unpackedLocation=get_param(modelName,'UnpackedLocation');
    if~isempty(unpackedLocation)
        partDir=fullfile(unpackedLocation,'autosar');
        if exist(fullfile(partDir,'autosar.xmi'),'file')
            origPath=addpath(partDir);
            restorePath=onCleanup(@()path(origPath));
        end
    end



    if includeComponents
        exporter.write(fileName);
    else
        compObj=autosar.api.Utils.m3iMappedComponent(modelName);
        exporter.split(compObj,fileName);


        toDeleteFileName=[compObj.Name,'_tedelete.arxml'];
        exporter.write(toDeleteFileName);
        if~isempty(dir(toDeleteFileName))
            delete(toDeleteFileName);
        end
    end

end


