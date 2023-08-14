classdef ArgumentParser<handle




    properties(SetAccess=private)
        ModelPeriodicRunnablesAs;
        DataDictionary;
        ShareAUTOSARProperties;
        PredefinedVariant;
        SystemConstValueSets;
        ComponentModels;
        UseBusElementPorts;
        ExcludeInternalBehavior;
        CreateDictionaryChangesReport;
        UseParallel;


        LaunchReport;
        OpenModel;
    end

    methods(Access=public)
        function this=ArgumentParser(varargin)
            argParser=inputParser;

            argParser.addParameter('ModelPeriodicRunnablesAs','Auto',...
            @(x)any(validatestring(x,{'Auto','AtomicSubsystem','FunctionCallSubsystem'})));
            argParser.addParameter('DataDictionary','',@(x)ischar(x)||isstring(x));
            argParser.addParameter('ShareAUTOSARProperties',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            argParser.addParameter('PredefinedVariant','',@(x)ischar(x)||isstring(x));
            argParser.addParameter('SystemConstValueSets',{},@cell);
            argParser.addParameter('ComponentModels',{},@(x)iscell(x)||ischar(x)||isstring(x));
            argParser.addParameter('ExcludeInternalBehavior',false,...
            @(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            argParser.addParameter('CreateDictionaryChangesReport',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));


            argParser.addParameter('LaunchReport','on',@(x)any(validatestring(x,{'on','off'})));
            argParser.addParameter('OpenModel',true,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            argParser.addParameter('ReadOnly',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));


            argParser.addParameter('ImportInternalTriggers',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            argParser.addParameter('UseBusElementPorts',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));
            argParser.addParameter('UseParallel',false,@(x)(autosar.api.internal.FunctionArgumentValidator.validateLogicalScalar(x)));


            argParser.parse(varargin{:});


            this.ModelPeriodicRunnablesAs=argParser.Results.ModelPeriodicRunnablesAs;
            this.DataDictionary=argParser.Results.DataDictionary;
            this.ShareAUTOSARProperties=argParser.Results.ShareAUTOSARProperties;
            this.PredefinedVariant=argParser.Results.PredefinedVariant;
            this.SystemConstValueSets=argParser.Results.SystemConstValueSets;

            componentModelsCell=argParser.Results.ComponentModels;
            if~iscell(argParser.Results.ComponentModels)
                componentModelsCell={argParser.Results.ComponentModels};
            end
            [~,this.ComponentModels,~]=cellfun(@fileparts,componentModelsCell,'UniformOutput',false);
            this.LaunchReport=argParser.Results.LaunchReport;
            this.OpenModel=argParser.Results.OpenModel;
            this.UseBusElementPorts=argParser.Results.UseBusElementPorts;
            this.ExcludeInternalBehavior=argParser.Results.ExcludeInternalBehavior;
            this.CreateDictionaryChangesReport=argParser.Results.CreateDictionaryChangesReport;
            this.UseParallel=argParser.Results.UseParallel;

            if this.ShareAUTOSARProperties&&isempty(this.DataDictionary)
                DAStudio.error('autosarstandard:importer:UnspecifiedDictionaryWithShareAUTOSARProperties');
            end
        end
    end
end


