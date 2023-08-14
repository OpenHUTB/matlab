function export(systemPath,varargin)


























    autosar.api.Utils.autosarlicensed(true);


    systemPath=convertStringsToChars(systemPath);
    for ii=1:length(varargin)
        if isstring(varargin{ii})
            varargin{ii}=convertStringsToChars(varargin{ii});
        end
    end



    rootModelName=get_param(bdroot(systemPath),'Name');
    systemToExport=getfullname(systemPath);


    if~autosar.composition.Utils.isModelInCompositionDomain(rootModelName)
        DAStudio.error('autosarstandard:exporter:ExportOnlySupportedForAUTOSARArchitectureModel',...
        systemToExport);
    end


    p=inputParser;
    p.addParameter('OkayToPushNags',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    codeGenFolder=RTW.getBuildDir(rootModelName).CodeGenFolder;
    arxmlFolderBase=i_getDefaultARXMLFolderBase(codeGenFolder,systemToExport);
    defaultZipFileName=fullfile(codeGenFolder,[get_param(systemToExport,'Name'),'.zip']);
    p.addParameter('ExportedARXMLFolder',arxmlFolderBase,...
    @(x)(ischar(x)||isStringScalar(x)));
    p.addParameter('PackageCodeAndARXML',defaultZipFileName,...
    @(x)(ischar(x)||isStringScalar(x)));
    p.addParameter('ExportECUExtract',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));

    p.parse(varargin{:});



    autosar_ui_close(rootModelName);

    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


        origModelStatus=get_param(rootModelName,'StatusString');
        restoreModelStatus=onCleanup(@()set_param(rootModelName,'StatusString',origModelStatus));


        bip=Simulink.BuildInProgress(rootModelName);%#ok<NASGU>



        arxmlFolder=p.Results.ExportedARXMLFolder;
        if~i_isExportForComponentBlock(systemToExport)
            arxmlFolder=fullfile(arxmlFolder,get_param(systemToExport,'Name'));
        end

        if slfeature('SaveAUTOSARCompositionAsArchModel')>0


            [isLinked,refModel]=autosar.arch.Utils.isModelBlock(systemToExport);
            if isLinked&&autosar.composition.Utils.isModelInCompositionDomain(refModel)
                systemToExport=refModel;
            end
        end


        if i_isExportForComponentBlock(systemToExport)




            if autosar.arch.Utils.isSubSystem(systemToExport)
                DAStudio.error(...
                'autosarstandard:exporter:ExportingNonLinkedComponentIsNotSupported',...
                getfullname(systemToExport));
            end



            if~isempty(arxmlFolder)
                DAStudio.error(...
                'autosarstandard:exporter:ExportedArxmlFolderNotSupportForComponents');
            end


            if p.Results.ExportECUExtract
                DAStudio.error(...
                'autosarstandard:exporter:ExportECUExtractNotSupportedForComponents');
            end
            compModelsInfo=[];
        else
            validator=autosar.composition.validation.Validator(systemToExport,...
            'ExportECUExtract',p.Results.ExportECUExtract);
            validator.verify();
            compModelsInfo=validator.getCompModelsToInfoMap();
        end


        zipFileName=i_getZipFileWithFullPath(codeGenFolder,p.Results.PackageCodeAndARXML);


        builder=autosar.composition.build.Builder(systemToExport,...
        'CompModelsInfo',compModelsInfo,...
        'OkayToPushNags',p.Results.OkayToPushNags,...
        'ExportedArxmlFolder',arxmlFolder,...
        'ExportECUExtract',p.Results.ExportECUExtract,...
        'ZipFileName',zipFileName);
        builder.build();

    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end

end


function zipFileFullPath=i_getZipFileWithFullPath(codeGenFolder,zipFileName)

    zipFileFullPath=zipFileName;

    if isempty(zipFileName)

        return;
    end



    if isempty(fileparts(zipFileName))
        zipFileFullPath=fullfile(codeGenFolder,zipFileName);
    end


    if~endsWith(zipFileFullPath,'.zip')
        zipFileFullPath=[zipFileFullPath,'.zip'];
    end
end

function tf=i_isExportForComponentBlock(systemToExport)
    tf=strcmp(get_param(systemToExport,'type'),'block')&&...
    autosar.composition.Utils.isComponentBlock(systemToExport);
end

function defaultExportedARXMLFolder=i_getDefaultARXMLFolderBase(codeGenFolder,systemToExport)
    if i_isExportForComponentBlock(systemToExport)

        defaultExportedARXMLFolder='';
    else
        defaultExportedARXMLFolder=codeGenFolder;
    end
end



