


classdef CheckModelForConversion<handle
    properties(Constant)
        ModifiedParameters={
        'SignalResolutionControl','UnderspecifiedInitializationDetection','FcnCallInpInsideContextMsg',...
        'Solver','SolverType','SampleTimeConstraint','ObfuscateCode'};
    end


    properties(SetAccess=protected,GetAccess=protected)
ModelName
ConversionParameters
ParameterMap
ConversionData
        UseConfigSetRef=false
    end



    methods(Access=public)
        function this=CheckModelForConversion(params)
            this.ConversionData=params;
            this.ConversionParameters=this.ConversionData.ConversionParameters;
            this.ModelName=get_param(this.ConversionParameters.Model,'Name');
            this.ParameterMap=this.ConversionData.ParameterMap;

            if~this.checkSimulationStatus&&~this.ConversionParameters.RightClickBuild
                error(message('Simulink:modelReference:convertToModelReference_BadSimulationStatus',...
                this.ModelName,get_param(this.ModelName,'SimulationStatus')));
            end
            this.UseConfigSetRef=isa(getActiveConfigSet(this.ModelName),'Simulink.ConfigSetRef');
        end

        function results=checkModelSettingsForExportedFunction(this,aModel)
            isRefModel=~strcmp(this.ModelName,aModel);
            results={};
            if~this.checkUnderspecifiedInitializationDetection(aModel)
                results=this.addMessage(message('Simulink:modelReferenceAdvisor:Initialization',aModel),results,isRefModel);
                this.createFixObject('UnderspecifiedInitializationDetection','Simplified',isRefModel);
            end

            if~this.checkFcnCallInpInsideContextMsg(aModel)
                results=this.addMessage(message('Simulink:modelReferenceAdvisor:ContextDepInputs',aModel),results,isRefModel);
                this.createFixObject('FcnCallInpInsideContextMsg','error',isRefModel);
            end

            if~this.checkSolver(aModel)
                results=this.addMessage(message('Simulink:modelReferenceAdvisor:Solver',aModel),results,isRefModel);
                this.createFixObject('Solver','FixedStepDiscrete',isRefModel);
            end

            isValidSolver=this.checkSolverType(aModel);
            if~isValidSolver
                results=this.addMessage(message('Simulink:modelReferenceAdvisor:SolverType',aModel),results,isRefModel);
                this.createFixObject('SolverType','Fixed-step',isRefModel);
                this.createFixObject('SampleTimeConstraint','Unconstrained',isRefModel);
            end


            if isValidSolver&&~this.checkSampleTimeConstraint(aModel)
                results=this.addMessage(message('Simulink:modelReferenceAdvisor:SampleTimeConstraint',aModel),results,isRefModel);
                this.createFixObject('SampleTimeConstraint','Unconstrained',isRefModel);
            end


            if this.ConversionParameters.ExportedFcn&&this.ConversionParameters.ReplaceSubsystem
                if~strcmp(get_param(aModel,'EnableRefExpFcnMdlSchedulingChecks'),'off')
                    this.ConversionData.Logger.addInfo(...
                    message('Simulink:modelReferenceAdvisor:EnableRefExpFcnMdlSchedulingChecks',aModel));
                    this.createFixObject('EnableRefExpFcnMdlSchedulingChecks','off',isRefModel);
                end
            end
        end

        function results=checkModelSettings(this)
            results=this.checkMdlSettings;
        end

        function results=checkTunableParameters(this)
            results={};
            checkObj=Simulink.ModelReference.Conversion.FixTunableParameters(...
            this.ModelName,this.ConversionData);
            if~checkObj.check
                isRefModel=false;
                results=this.addMessage(...
                message('Simulink:modelReferenceAdvisor:TunableVarsTableNotEmpty'),results,isRefModel);
                this.ConversionData.addTopModelFixObj(checkObj);
            end
        end
    end

    methods(Access=protected)
        function results=checkMdlSettings(this)
            if~this.checkSignalResolutionControl
                this.ConversionData.Logger.addWarning(...
                message('Simulink:modelReferenceAdvisor:InvalidSignalResolution'));
            end


            this.checkFunctionPlatformCodeMappings;


            results=this.checkTunableParameters;
        end

        function createFixObject(this,paramName,newValue,isRefModel)
            if isRefModel&&~this.UseConfigSetRef


                this.createRefModelsFixObject(paramName,newValue);
            end

            this.createTopModelFixObject(paramName,newValue);
        end

        function createTopModelFixObject(this,paramName,newValue)
            this.ConversionData.addTopModelFixObj(...
            Simulink.ModelReference.Conversion.FixParameters(this.ModelName,paramName,newValue,this.ConversionData));
        end
    end


    methods(Access=private)
        function results=addMessage(this,aMsg,results,isRefModel)
            if this.ConversionParameters.RightClickBuild||isRefModel
                this.ConversionData.Logger.addInfo(aMsg);
            else
                results{end+1}=aMsg;
            end
        end


        function status=checkSimulationStatus(this)
            status=strcmpi(get_param(this.ModelName,'SimulationStatus'),'stopped');
        end

        function status=checkSignalResolutionControl(this)
            signalResolutionControl=get_param(this.ModelName,'SignalResolutionControl');
            status=(strcmpi(signalResolutionControl,'None')||...
            strcmpi(signalResolutionControl,'UseLocalSettings'));
        end

        function checkFunctionPlatformCodeMappings(this)
            if~this.ConversionParameters.CopyCodeMappings

                return;
            end
            ertMdlMapping=Simulink.CodeMapping.get(this.ModelName,'CoderDictionary');
            grtMdlMapping=Simulink.CodeMapping.get(this.ModelName,'SimulinkCoderCTarget');
            if~isempty(ertMdlMapping)&&ertMdlMapping.isFunctionPlatform
                if isempty(grtMdlMapping)


                    msg=message('coderdictionary:mapping:SubsystemConversionForFunctionPlatformError',this.ModelName);
                    error(msg);
                else




                    msg=message('coderdictionary:mapping:SubsystemConversionForFunctionPlatformWarn',this.ModelName);
                    this.ConversionData.Logger.addWarning(msg);
                end
            end
        end

        function status=checkTaskingMode(this)
            status=strcmpi(get_param(this.ModelName,'EnableMultiTasking'),'on');
        end

        function createRefModelsFixObject(this,paramName,newValue)
            for idx=1:numel(this.ConversionParameters.ModelReferenceNames)
                aModel=this.ConversionParameters.ModelReferenceNames{idx};
                this.ConversionData.addNewModelFixObj(...
                Simulink.ModelReference.Conversion.FixParameters(aModel,paramName,newValue,this.ConversionData));
            end
        end
    end

    methods(Static,Access=private)
        function status=checkUnderspecifiedInitializationDetection(aModel)
            status=strcmpi(get_param(aModel,'UnderspecifiedInitializationDetection'),'Simplified');
        end

        function status=checkFcnCallInpInsideContextMsg(aModel)
            contextDepInputs=get_param(aModel,'FcnCallInpInsideContextMsg');
            status=strcmpi(contextDepInputs,'error');
        end

        function status=checkSolver(aModel)
            status=strcmpi(get_param(aModel,'Solver'),'FixedStepDiscrete')...
            ||slfeature('RelaxVarStepSolverForExportFcnMdl')>0;
        end

        function status=checkSolverType(aModel)
            status=strcmpi(get_param(aModel,'SolverType'),'Fixed-step');
        end

        function status=checkSampleTimeConstraint(aModel)
            status=strcmpi(get_param(aModel,'SampleTimeConstraint'),'Unconstrained');
        end
    end
end


