function[success]=createCalibrationComponentObjects(this,ComponentName,varargin)































    success=false;%#ok


    argParser=inputParser;


    argParser.addRequired('this',@(x)isa(x,class(x)));
    argParser.addRequired('ComponentName',@(x)(ischar(x)||isStringScalar(x)));
    argParser.addParameter('DataDictionary','',@(x)(ischar(x)||isStringScalar(x)));


    argParser.addParameter('CreateSimulinkObject',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
    argParser.addParameter('NameConflictAction','overwrite',@(x)any(strcmpi(x,{'overwrite','makenameunique','error'})));
    argParser.addParameter('UseLegacyWorkspaceBehavior',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));


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


        p_create_calib_component(this,argParser);
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end
    success=true;


