




classdef ConversionParametersForCLI<Simulink.ModelReference.Conversion.ConversionParameters
    properties(Access=private)
        SupportedSimulationModes={'Normal','Accelerator','Software-in-the-loop (SIL)'};
        SupportedBuildTargets={'Sim','RTW','Coder'};
        BuildTargets={'ModelReferenceSimTarget','ModelReferenceCoderTarget','ModelReferenceCoderTarget'};
    end

    properties(Constant)
        SupportDataFileFormat={'.mat','.m'};
    end

    methods(Access=public)
        function this=ConversionParametersForCLI(varargin)
            this@Simulink.ModelReference.Conversion.ConversionParameters(varargin{:});
            Simulink.ModelReference.Conversion.FileUtils.checkFileName(this.DataFileName);
        end
    end

    methods(Access=protected)
        function parseInputParameters(this,varargin)
            subsysNames=varargin{1};
            modelRefNames=varargin{2};


            this.getSystemInfo(subsysNames);
            this.getReferencedModelNames(modelRefNames);


            inputParameters=varargin(3:end);
            params=this.parseInputArguments(get_param(this.Model,'Name'),inputParameters{:});


            this.DataFileName=params.DataFileName;
            if~any(strcmp(inputParameters,'DataFileName'))
                maxiter=1000;
                fileName=params.DataFileName;
                dotPos=strfind(fileName,'.');
                baseName=fileName(1:dotPos-1);
                underscorePlace=strfind(baseName,'_');
                underscorePlace=underscorePlace(1);
                baseName=baseName(underscorePlace:end);
                if iscell(modelRefNames)
                    modelRefNames=modelRefNames{:};
                end
                baseName=[modelRefNames,baseName];
                dataName=baseName;
                ii=0;
                while(exist([dataName,'.mat'])==2&&ii<maxiter)%#ok
                    dataName=[baseName,num2str(ii)];
                    ii=ii+1;
                end

                this.DataFileName=[dataName,'.mat'];
                params.DataFileName=[dataName,'.mat'];
            end
            this.validateDataFileName(this.DataFileName);
            this.ReplaceSubsystem=params.ReplaceSubsystem;
            this.Force=params.Force;
            this.ExportedFcn=params.ExportedFunctionSubsystem;
            this.UseAutoFix=params.AutoFix;
            this.UseConversionAdvisor=params.UseConversionAdvisor;
            this.PropagateSignalStorageClass=params.PropagateSignalStorageClass;
            this.CheckSimulationResults=params.CheckSimulationResults;
            this.SimulationModes=params.SimulationModes;
            cellfun(@(simMode)this.validateSimulationModes(simMode),this.SimulationModes);
            this.StopTime=params.StopTime;
            this.RelativeTolerance=params.RelativeTolerance;
            this.AbsoluteTolerance=params.AbsoluteTolerance;
            this.CopySubsystemMaskToNewModel=params.CopySubsystemMaskToNewModel;
            this.CreateBusObjectsForAllBuses=params.CreateBusObjectsForAllBuses;
            this.CopyCodeMappings=params.CopyCodeMappings;

            if~isempty(params.BuildTarget)
                aMask=strcmp(this.SupportedBuildTargets,params.BuildTarget);
                if~any(aMask)
                    throw(MException(message('Simulink:modelReference:convertToModelReference_BuildTarget')));
                end
                this.BuildTarget=this.BuildTargets{aMask};
            else
                this.BuildTarget='';
            end


            this.CreateWrapperSubsystem=params.CreateWrapperSubsystem;
            this.RestoreSubsystemIfFailed=params.RestoreSubsystemIfFailed;
            this.TimeOut=params.TimeOut;


            this.RightClickBuild=params.RightClickBuild;
            this.ExpFcnInitFcnName=params.ExpFcnInitFcnName;
            this.CopySubsystem=params.CopySubsystem;
            this.SS2mdlForSLDV=params.SS2mdlForSLDV;
            this.SS2mdlForPLC=params.SS2mdlForPLC;

            this.UseConversionDialog=params.UseConversionDialog;



            this.ExpandVirtualBusPorts=params.ExpandVirtualBusPorts;
            if this.ExpandVirtualBusPorts
                this.UseAutoFix=true;
            end
        end
    end


    methods(Static,Access=private)
        function validateDataFileName(fileName)
            [~,~,fileExt]=fileparts(fileName);
            if~any(strcmpi(Simulink.ModelReference.Conversion.ConversionParametersForCLI.SupportDataFileFormat,fileExt))
                error(message('Simulink:modelReferenceAdvisor:InvalidDataFileExtention',fileExt,...
                Simulink.ModelReference.Conversion.ConversionParametersForCLI.SupportDataFileFormat{1},...
                Simulink.ModelReference.Conversion.ConversionParametersForCLI.SupportDataFileFormat{2}));
            end
        end
    end


    methods(Access=private)
        function validateSimulationModes(this,simMode)
            if~any(strcmp(this.SupportedSimulationModes,simMode))
                throw(MException(message('Simulink:modelReferenceAdvisor:InvalidModelBlockSimulationMode',simMode)));
            end
        end
    end
end
