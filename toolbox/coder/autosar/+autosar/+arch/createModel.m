function archModel=createModel(modelName,varargin)








    narginchk(1,2);

    try
        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

        p=inputParser;
        p.addRequired('modelName',@(x)(ischar(x)||isStringScalar(x)));
        p.addOptional('openFlag',true,...
        @(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
        p.parse(modelName,varargin{:});


        bd=new_system(modelName,'AUTOSARArchitecture');
        autosarcore.setArchModelCallbacks(bd);


        archModel=autosar.arch.Model.create(bd);


        if p.Results.openFlag
            archModel.open();
        end

    catch ME
        autosar.mm.util.MessageReporter.throwException(ME);
    end


