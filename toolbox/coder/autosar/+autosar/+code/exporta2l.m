function exporta2l(modelName,varargin)




























































    MSLDiagnostic('autosarstandard:api:invalidExportA2lAPI').reportAsError;

    autosar.api.Utils.autosarlicensed(true);

    if nargin>0
        modelName=convertStringsToChars(modelName);
    end


    argParser=inputParser;


    argParser.addParameter('MapFile','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('Folder','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('ModelClassInstanceName','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('GenerateXCPInfo',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('Comments',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('Version','',@(x)any(validatestring(x,...
    coder.asap2.getASAP2SupportedVersions())));
    argParser.addParameter('CustomizationObject','',@(x)(isobject(x)));
    argParser.addParameter('Filename','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('IndentFile',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('CustomizeGroupsBy','',@(x)(coder.asap2.isValidGroupType(x)));
    argParser.addParameter('IncludeAllRecordLayouts',false,@(x)(isa(x,'logical')));
    argParser.addParameter('SupportStructureElements',true,@(x)(isa(x,'logical')));
    argParser.addParameter('Support64bitIntegers',true,@(x)(isa(x,'logical')));



    argParser.addParameter('EcuAddressExtension',32768,@(x)(isnumeric(x)&&floor(x)==ceil(x)&&(x>-32768)&&(x<32767)));
    argParser.addParameter('UseModifiedData',containers.Map,@(x)(isa(x,'coder.internal.asap2.Data')));
    argParser.parse(varargin{:});


    systems=find_system('type','block_diagram','name',modelName);
    if isempty(systems)
        DAStudio.error('RTW:autosar:mdlNotLoaded',modelName);
    end


    isCompliant=Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName);
    if~isCompliant
        DAStudio.error('autosarstandard:api:a2lExportCompliant');
    end

    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>
        obj=coder.internal.asap2.Generator(modelName,convertStringsToChars(argParser.Results.Version));

        buildDir=RTW.getBuildDir(modelName);
        if exist(buildDir.BuildDirectory,'dir')~=7
            error(message('codedescriptor:core:ModelIsNotBuilt',modelName));
        end

        if~isempty(argParser.Results.MapFile)
            if~exist(argParser.Results.MapFile,'file')
                DAStudio.error('RTW:asap2:UnableFindFile',argParser.Results.MapFile);
            end
        end

        folderPath=convertStringsToChars(argParser.Results.Folder);
        if~isempty(argParser.Results.Folder)
            if exist(argParser.Results.Folder,'dir')~=7



                if~ispc
                    folderPath=replace(folderPath,'\','/');
                end
                mkdir(folderPath);
            end
            exportLocation=convertStringsToChars(folderPath);
        else
            exportLocation=buildDir.BuildDirectory;
        end

        if~isempty(argParser.Results.Filename)
            a2lFilePath=fullfile(exportLocation,argParser.Results.Filename);
        else
            a2lFilePath=fullfile(exportLocation,[modelName,'.a2l']);
        end

        if~isempty(argParser.Results.Comments)
            includeComments=argParser.Results.Comments;
        else
            includeComments=true;
        end
        usingUserCustomizationObj=argParser.Results.CustomizationObject;
        systemTargetFile=get_param(modelName,'SystemTargetFile');
        modelPath=which(modelName);
        modelInfo=Simulink.MDLInfo(modelPath);
        modelClassInstanceName=convertStringsToChars(argParser.Results.ModelClassInstanceName);
        includeXCPInfo=argParser.Results.GenerateXCPInfo;
        customizeGroups=argParser.Results.CustomizeGroupsBy;
        includeAllRecordLayouts=argParser.Results.IncludeAllRecordLayouts;
        supportStructureElements=argParser.Results.SupportStructureElements;
        support64bitIntegers=argParser.Results.Support64bitIntegers;
        ecuAddressExtension=argParser.Results.EcuAddressExtension;
        includeRTEElements=false;
        useModifiedData=argParser.Results.UseModifiedData;
        info=obj.generate(a2lFilePath,modelClassInstanceName,customizeGroups,supportStructureElements,support64bitIntegers,includeRTEElements,useModifiedData,systemTargetFile,modelInfo.ModelVersion,includeComments,usingUserCustomizationObj,includeAllRecordLayouts,ecuAddressExtension);

        if~isempty(argParser.Results.MapFile)
            rtw.asap2SetAddress(a2lFilePath,argParser.Results.MapFile);
        end



        if includeXCPInfo
            coder.internal.asap2.AddXCPInfoToAdaptiveASAP2(modelName,a2lFilePath,argParser);
        end
        if argParser.Results.IndentFile
            coder.internal.asap2.addIndentationToFile(a2lFilePath,exportLocation);
        end
        if~isempty(info)
            fprintf("%s",message('RTW:asap2:NoElementInASAP2',strjoin(info,', ')));
        end
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end
end


