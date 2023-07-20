




classdef ParameterMap<handle
    properties(Access=private)
Parameters
Values
    end


    methods(Access=public)
        function this=ParameterMap()
            this.init;
        end


        function results=getParamName(this,paramName)
            if this.Parameters.isKey(paramName)
                results=this.Parameters(paramName);
            else
                results=['''',paramName,''''];
            end
        end

        function results=getParamValue(this,paramName,paramValue)
            if ischar(paramValue)
                key=[paramName,':',paramValue];
                if this.Values.isKey(key)
                    results=this.Values(key);
                else
                    results=paramValue;
                end
            else
                results=paramValue;
            end
        end
    end


    methods(Hidden,Access=public)
        function params=getParameters(this)
            params=this.Parameters;
        end
    end


    methods(Access=private)
        function init(this)
            this.Parameters=containers.Map;
            this.Values=containers.Map;


            if slfeature('InlinePrmsAsCodeGenOnlyOption')==0
                this.Parameters('InlineParams')=DAStudio.message('RTW:configSet:optInlineParamName');
            else
                this.Parameters('DefaultParameterBehavior')=DAStudio.message('RTW:configSet:optDefaultParamBehaviorName');
            end
            this.Parameters('SignalResolutionControl')=DAStudio.message('RTW:configSet:debugSignalResControlName');
            this.Parameters('UnderspecifiedInitializationDetection')=DAStudio.message('RTW:configSet:debugDetectUnderspecifiedInitName');
            this.Parameters('FcnCallInpInsideContextMsg')=DAStudio.message('RTW:configSet:debugFcnCallInpInCtxtName');
            this.Parameters('Solver')=DAStudio.message('RTW:configSet:SolverSolverName');
            this.Parameters('SolverType')=DAStudio.message('RTW:configSet:SolverSolverTypeName');
            this.Parameters('SampleTimeConstraint')=DAStudio.message('RTW:configSet:SolverStConstraintName');
            this.Parameters('EnableMultiTasking')=DAStudio.message('RTW:configSet:EnableMultiTaskingName');
            this.Parameters('TreatAsAtomicUnit')=DAStudio.message('Simulink:blkprm_prompts:SubsysTreatAtomic');


            this.Values('SignalResolutionControl:None')=DAStudio.message('RTW:configSet:debugSignalResolutionNone');
            this.Values('SignalResolutionControl:UseLocalSettings')=DAStudio.message('RTW:configSet:debugSignalResolutionExplicit');
            this.Values('SignalResolutionControl:TryResolveAll')=DAStudio.message('RTW:configSet:debugSignalResolutionExplicitAndImplicit');
            this.Values('SignalResolutionControl:TryResolveAllWithWarning')=DAStudio.message('RTW:configSet:debugSignalResolutionExplicitAndWarnImplicit');

            this.Values('Solver:FixedStepDiscrete')=DAStudio.message('SimulinkExecution:SolverDescription:Discrete');

            this.Values('FcnCallInpInsideContextMsg:error')=DAStudio.message('RTW:configSet:debugComboBoxValueError');
            this.Values('FcnCallInpInsideContextMsg:warning')=DAStudio.message('RTW:configSet:debugComboBoxValueWarning');
        end
    end
end
