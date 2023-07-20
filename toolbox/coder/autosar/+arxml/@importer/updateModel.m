function updateModel(this,modelName,varargin)
































    argParser=inputParser;
    argParser.addRequired('ModelName',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('PredefinedVariant','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('SystemConstValueSets',{},@(x)(iscell(x)));


    argParser.addParameter('LaunchReport','on',@(x)any(validatestring(x,{'on','off'})));


    argParser.addParameter('ImportInternalTriggers',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));


    modelName=convertStringsToChars(modelName);
    for ii=1:length(varargin)
        if isstring(varargin{ii})
            varargin{ii}=convertStringsToChars(varargin{ii});
        end
    end


    argParser.parse(modelName,varargin{:});


    [~,modelName]=fileparts(modelName);

    args={};
    if~isempty(argParser.Results.PredefinedVariant)
        args=[args,'PredefinedVariant',argParser.Results.PredefinedVariant];
    end
    if~isempty(argParser.Results.SystemConstValueSets)
        args=[args,'SystemConstValueSets',argParser.Results.SystemConstValueSets];
    end

    args=[args,'LaunchReport',argParser.Results.LaunchReport...
    ,'ImportInternalTriggers',argParser.Results.ImportInternalTriggers];

    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


        loc_errorOutForUnsupportedWorkflows(modelName);

        p_updateModel(this,modelName,args{:});
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end

end

function loc_errorOutForUnsupportedWorkflows(modelName)




    if~Simulink.CodeMapping.isMappedToAutosarSubComponent(modelName)
        interfaceDicts=SLDictAPI.getTransitiveInterfaceDictsForModel(modelName);
        if~isempty(interfaceDicts)
            dictsNoPath=autosar.utils.File.dropPath(interfaceDicts);
            DAStudio.error('interface_dictionary:workflows:NotSupportedForModelLinkedToInterfaceDict',...
            'arxml.importer.updateModel',modelName,autosar.api.Utils.cell2str(dictsNoPath));
        end
    end


    if autosar.composition.Utils.isModelInCompositionDomain(modelName)
        DAStudio.error('autosarstandard:api:CapabilityNotSupportForAUTOSARArchitectureModel',...
        'arxml.importer.updateModel');
    end



    if autosar.api.Utils.isMappedToComponent(modelName)&&...
        autosar.api.Utils.isUsingSharedAutosarDictionary(modelName)
        ddName=get_param(modelName,'DataDictionary');
        DAStudio.error('autosarstandard:importer:ComponentUpdateModelNotSupportedWithShareAUTOSARProperties',...
        modelName,ddName);
    end

end


