


classdef ConversionParameters<handle
    properties(Hidden,SetAccess=public,GetAccess=public)
        ExportedFcn=false
        CreateWrapperSubsystem=false;
        Systems=[]
    end

    properties(Transient,SetAccess=public,GetAccess=public)
        UseAutoFix=false;
        CopySubsystem=false;
        CreateBusObjectsForAllBuses=false;
    end

    properties(Transient,SetAccess=protected,GetAccess=public)
Model
        ModelReferenceNames={}
SystemNames
DataFileName
        ReplaceSubsystem=false
        BuildTarget=''
        Force=false
        UseConversionAdvisor=false
        PropagateSignalStorageClass=false
        CheckSimulationResults=false
StopTime
AbsoluteTolerance
RelativeTolerance
SimulationModes
        RestoreSubsystemIfFailed=false;
        CopySubsystemMaskToNewModel=false;
        RightClickBuild=false;
        ExpFcnInitFcnName='';
        TimeOut=-1;
        UseConversionDialog=false;
        ExpandVirtualBusPorts=false;
        SS2mdlForSLDV=false;
        SS2mdlForPLC=false;
        CopyCodeMappings=false;
    end

    properties(SetAccess=private,GetAccess=private)
SystemSIDs
    end



    methods(Static,Access=public)
        function params=create(varargin)












            switch nargin
            case 0
                throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidNumInputs')));

            case 1
                params=Simulink.ModelReference.Conversion.ConversionParametersForCheckOnlyMode(varargin{1});

            case 3
                params=Simulink.ModelReference.Conversion.ConversionParametersForGUI(varargin{:});

            otherwise
                params=Simulink.ModelReference.Conversion.ConversionParametersForCLI(varargin{:});
            end
        end


        function validateModelReferenceName(modelName,dataAccessor)
            maxLength=namelengthmax-4;
            if length(modelName)>maxLength
                throw(MException(message('Simulink:modelReferenceAdvisor:LongModelName',maxLength+1)));
            end

            if~Simulink.ModelReference.Conversion.NameUtils.isModelNameValid(modelName)
                throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidModelRef',modelName)));
            end

            if Simulink.ModelReference.Conversion.NameUtils.doesModelNameExist(modelName)
                throw(MException(message('Simulink:modelReference:convertToModelReference_ModelRefFileExisted',modelName,modelName)));
            end

            if~isempty(dataAccessor.identifyByName(modelName))
                throw(MException(message('Simulink:modelReferenceAdvisor:ReferencedModelAndVariableHaveSameName',modelName,modelName)));
            end
        end


        function fileName=getDataFileName(suggestedName)
            fileName=[matlab.lang.makeValidName(suggestedName),'_conversion_data.mat'];
        end
    end


    methods(Access=public)
        function ssName=getSystemName(this,subsysH)
            ssName=this.SystemNames{this.Systems==subsysH};
        end

        function sid=getSystemSIDs(this,subsysH)
            sid=this.SystemSIDs{this.Systems==subsysH};
        end
    end


    methods(Abstract,Access=protected)
        parseInputParameters(this,varargin);
    end


    methods(Access=protected)
        function this=ConversionParameters(varargin)
            this.parseInputParameters(varargin{:});
            this.SystemNames=arrayfun(@(ss)getfullname(ss),this.Systems,'UniformOutput',false);
            this.SystemSIDs=arrayfun(@(ss)Simulink.ID.getSID(ss),this.Systems,'UniformOutput',false);
        end


        function getSystemInfo(this,subsys)
            this.Systems=Simulink.ModelReference.Conversion.Utilities.getHandles(subsys);
            arrayfun(@(ss)this.checkNoReadOrWriteSubsystem(ss),this.Systems);
            assert(all(ishandle(this.Systems)),'A given input parameter must be a handle or an array of handle!');
            this.Model=bdroot(this.Systems(1));
        end


        function getReferencedModelNames(this,referencedModelNames)
            this.ModelReferenceNames=Simulink.ModelReference.Conversion.Utilities.cellify(referencedModelNames);
            dataAccessor=Simulink.data.DataAccessor.createForExternalData(this.Model);
            cellfun(@(modelName)this.validateModelReferenceName(modelName,dataAccessor),this.ModelReferenceNames);
        end
    end


    methods(Static,Access=protected)
        function params=parseInputArguments(modelName,varargin)
            p=inputParser;

            addOptional(p,'ReplaceSubsystem',false,@islogical);
            addOptional(p,'Force',false,@islogical);
            addOptional(p,'ExportedFunctionSubsystem',false,@islogical);
            addOptional(p,'AutoFix',false,@islogical);
            addOptional(p,'UseConversionAdvisor',false,@islogical);
            addOptional(p,'PropagateSignalStorageClass',false,@islogical);
            addOptional(p,'CheckSimulationResults',false,@islogical);
            addOptional(p,'DataFileName',Simulink.ModelReference.Conversion.ConversionParameters.getDataFileName(modelName),@ischar);
            addOptional(p,'BuildTarget','',@ischar);
            addOptional(p,'CreateWrapperSubsystem',false,@islogical);
            addOptional(p,'RestoreSubsystemIfFailed',false,@islogical);
            addOptional(p,'CopySubsystemMaskToNewModel',false,@islogical);
            addOptional(p,'TimeOut',-1,@isfloat);


            defaultAbsoluteTolerance=Simulink.SDIInterface.calculateDefaultAbsoluteTolerance(modelName);
            defaultRelativeTolerance=Simulink.SDIInterface.calculateDefaultRelativeTolerance(modelName);
            addOptional(p,'SimulationModes',{'Normal'},@iscellstr);
            addOptional(p,'AbsoluteTolerance',defaultAbsoluteTolerance,@isfloat);
            addOptional(p,'RelativeTolerance',defaultRelativeTolerance,@isfloat);
            addOptional(p,'StopTime',Simulink.SDIInterface.DefaultStopTime,@isfloat);
            addOptional(p,'BusSaveFormat','',@Simulink.ModelReference.Conversion.ConversionParameters.warnAboutBusOptions);
            addOptional(p,'BusFileName','',@Simulink.ModelReference.Conversion.ConversionParameters.warnAboutBusOptions);


            addOptional(p,'UseConversionDialog',false,@islogical);
            addOptional(p,'RightClickBuild',false,@islogical);
            addOptional(p,'ExpFcnInitFcnName','',@ischar);
            addOptional(p,'ExpandVirtualBusPorts',false,@islogical);

            addOptional(p,'CopySubsystem',false,@islogical);




            addOptional(p,'SS2mdlForSLDV',false,@islogical);
            addOptional(p,'SS2mdlForPLC',false,@islogical);




            addOptional(p,'CreateBusObjectsForAllBuses',false,@islogical);
            addOptional(p,'CopyCodeMappings',false,@islogical);

            parse(p,varargin{:});
            params=p.Results;
        end
    end


    methods(Static,Access=private)
        function isOK=warnAboutBusOptions(~)
            MSLDiagnostic('Simulink:modelReferenceAdvisor:WarnAboutBusOptions').reportAsWarning;
            isOK=true;
        end

        function checkNoReadOrWriteSubsystem(currentSystem)
            ssType=Simulink.SubsystemType(currentSystem);
            if ssType.isSubsystem
                permissions=get_param(currentSystem,'Permissions');


                if strcmp(permissions,'NoReadOrWrite')
                    ssName=Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(...
                    getfullname(currentSystem),currentSystem);
                    throw(MException(message('Simulink:modelReferenceAdvisor:NoReadOrWriteSubsystem',ssName)));
                end
            end
        end
    end
end


