function arxmlFiles=getExportedArxmlFileNames(modelName,varargin)





















    autosar.api.Utils.autosarlicensed(true);
    arxmlFiles={};


    argParser=inputParser;
    argParser.addParameter('IncludeStubFiles',false,@(x)islogical(x));
    argParser.parse(varargin{:});

    if nargin>0
        modelName=convertStringsToChars(modelName);
    end


    systems=find_system('type','block_diagram','name',modelName);
    if isempty(systems)
        DAStudio.error('RTW:autosar:mdlNotLoaded',modelName);
    end


    isCompliant=strcmp(get_param(modelName,'AutosarCompliant'),'on');
    if~isCompliant
        DAStudio.error('RTW:autosar:nonAutosarCompliant');
    end

    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


        modelArxmlDir=autosar.mm.arxml.Exporter.getModelArxmlFolder(modelName);
        if exist(modelArxmlDir,'dir')~=7
            DAStudio.error('autosarstandard:api:CannotFindBuildFolderForArxml',...
            modelArxmlDir,modelName);
        end
        modelArxmlFiles=i_collectArxmlFilesInFolder(modelArxmlDir);
        arxmlFiles=[arxmlFiles,modelArxmlFiles];


        [isRefSharedDict,dictFiles]=autosar.api.Utils.isUsingSharedAutosarDictionary(modelName);
        if isRefSharedDict
            buildDir=RTW.getBuildDir(modelName);
            assert(numel(dictFiles)==1,'Expected model to be linked to a single shared AUTOSAR dictionary.');
            [~,dictionaryFolder,~]=fileparts(dictFiles{1});
            if strcmp(pwd,buildDir.BuildDirectory)
                dictionaryFolder=fullfile('..',dictionaryFolder);
            end
            dictArxmlDictFiles=i_collectArxmlFilesInFolder(dictionaryFolder);
            arxmlFiles=[arxmlFiles,dictArxmlDictFiles];

            if argParser.Results.IncludeStubFiles
                dictArxmlStubDir=fullfile(dictionaryFolder,autosar.mm.arxml.Exporter.StubFolderName);
                dictArxmlStubFiles=i_collectArxmlFilesInFolder(dictArxmlStubDir);
                arxmlFiles=[arxmlFiles,dictArxmlStubFiles];
            end
        end


        if argParser.Results.IncludeStubFiles
            modelArxmlStubDir=autosar.mm.arxml.Exporter.getModelArxmlStubFolder(modelName);
            modelArxmlStubFiles=i_collectArxmlFilesInFolder(modelArxmlStubDir);
            arxmlFiles=[arxmlFiles,modelArxmlStubFiles];
        end
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end

end




function arxmlFiles=i_collectArxmlFilesInFolder(folder)
    arxmlFiles={};
    if(exist(folder,'dir')~=7)
        return;
    end

    files=dir(fullfile(folder,'*.arxml'));
    for fileIdx=1:length(files)
        file=fullfile(files(fileIdx).folder,files(fileIdx).name);
        if(exist(file,'file')==2)
            arxmlFiles{end+1}=file;%#ok<AGROW>
        end
    end
end


