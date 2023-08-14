function[modelH,success]=createComponentAsModel(this,ComponentName,varargin)




























































    success=false;
    modelH=-1;


    argParser=inputParser;


    argParser.addRequired('this',@(x)isa(x,class(x)));
    argParser.addRequired('ComponentName',@(x)validateattributes(x,{'char','string'},{'scalartext'}));
    argParser.addParameter('ModelPeriodicRunnablesAs','AtomicSubsystem',...
    @(x)any(validatestring(x,{'Auto','AtomicSubsystem','FunctionCallSubsystem'})));
    argParser.addParameter('InitializationRunnable','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('DataDictionary','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('PredefinedVariant','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('SystemConstValueSets',{},@(x)(iscell(x)));


    argParser.addParameter('CreateSimulinkObject',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('NameConflictAction','overwrite',@(x)any(strcmpi(x,{'overwrite','makenameunique','error'})));
    argParser.addParameter('AutoSave',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('CreateInternalBehavior',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('OpenModel',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    if slfeature('ImportComponentModelsUsingSharedAUTOSARDictionary')>0
        argParser.addParameter('ShareAUTOSARProperties',false,@islogical);
        argParser.addParameter('CreateDictionaryChangesReport',false,@islogical);
    end
    argParser.addParameter('ResetRunnables','',@(x)(ischar(x)||isstring(x)||iscellstr(x)));
    argParser.addParameter('TerminateRunnable','',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('ForceLegacyWorkspaceBehavior',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('UseBusElementPorts',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('UseValueTypes',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));


    argParser.addParameter('ImportInternalTriggers',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));


    ComponentName=convertStringsToChars(ComponentName);
    for ii=1:length(varargin)
        if isstring(varargin{ii})
            varargin{ii}=convertStringsToChars(varargin{ii});
        end
    end


    argParser.parse(this,ComponentName,varargin{:});

    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


        autosar.mm.mm2sl.utils.checkAndCreateDD(argParser.Results.DataDictionary);


        [modelH,success]=p_create_slcomponent(this,argParser);
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end


