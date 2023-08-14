classdef(Sealed)VerificationResult<handle&matlab.mixin.CustomDisplay


























    properties(Constant,Hidden)
        InvalidRun='Invalid RunName';
    end

    properties(SetAccess=private,Dependent,Hidden)
        ConstraintSettings;
        StatusCode;
    end

    properties(SetAccess=private)
        ScenarioResults=DataTypeWorkflow.VerificationResult.empty;
    end

    properties(SetAccess=private,Dependent)
        RunName;
        BaselineRunName;
        Status;
        MaxDifference;
    end

    properties(SetAccess=private,GetAccess=private)

        AutoscalerDesignResult;
        DataLayer;
        IsValid=true;


        pRunName;
        pBaselineRunName;
        pStatusCode;
    end

    methods(Access={?DataTypeWorkflow.Converter,?fxptui.Web.CallbackService.CompareRunsHandler,?DataTypeWorkflowTestCase})

        function this=VerificationResult(autoscalerDesignResult)


            this.AutoscalerDesignResult=autoscalerDesignResult;
            this.DataLayer=fxptds.DataLayerInterface.getInstance();

            this.initialize();

        end

        function overwriteBaselineRunName(this,newRunName)


            originalBaselineName=this.BaselineRunName;
            if~strcmp(originalBaselineName,newRunName)
                this.pBaselineRunName=newRunName;


                if this.AutoscalerDesignResult.VerificationStatus~=fxptds.VerificationStatus.NotApplicable

                    this.pStatusCode=fxptds.VerificationStatus.UnknownBaseline;
                end

                if numel(this.ScenarioResults)>0

                    facade=this.DataLayer.getWorkflowTopologyFacade(this.AutoscalerDesignResult.TopModel);


                    [~,baselineFPTRunID]=this.DataLayer.getIdFromRunName(this.AutoscalerDesignResult.TopModel,newRunName);
                    parentFPTRunIDs=facade.query(baselineFPTRunID,'property','Name','search','parents','type','Collection','sortDirection','ascend');



                    if numel(parentFPTRunIDs)==numel(this.ScenarioResults)

                        for idx=1:numel(parentFPTRunIDs)
                            scenarioResult=this.ScenarioResults(idx);
                            parentFPTRunID=str2double(parentFPTRunIDs{idx});
                            newScenarioBaselineRunName=this.getRunName(parentFPTRunID);



                            scenarioResult.overwriteBaselineRunName(newScenarioBaselineRunName);
                        end
                    end
                end
            end
        end

    end

    methods

        function explore(this,varargin)









            if isempty(varargin)
                if isempty(this.ScenarioResults)
                    index=0;
                else
                    index=1;
                end
            else
                index=varargin{1};


                validateattributes(index,{'numeric'},{'scalar','positive','real','integer','<=',numel(this.ScenarioResults)});
            end

            if index<1
                baselineRunName=this.BaselineRunName;
                verificationRunName=this.RunName;
                [sdiBaseline,~]=this.DataLayer.getIdFromRunName(this.AutoscalerDesignResult.TopModel,baselineRunName);
                [sdiVerify,~]=this.DataLayer.getIdFromRunName(this.AutoscalerDesignResult.TopModel,verificationRunName);

                if this.StatusCode==fxptds.VerificationStatus.NoSignalsLogged
                    errorMessage=message('FixedPointTool:fixedPointTool:NoSignalsWithLoggingOn');
                elseif isempty(sdiBaseline)||isempty(sdiVerify)
                    errorMessage=message('SimulinkFixedPoint:autoscaling:signalIDNotMatch');
                else
                    errorMessage=[];

                    baselineComparisonUtil=DataTypeOptimization.SDIBaselineComparison();


                    baselineComparisonUtil.clearSignalTolerances(sdiBaseline);


                    optOptions=this.ConstraintSettings.getOptimizationOptions;
                    baselineComparisonUtil.bindConstraints(sdiBaseline,optOptions.Constraints.values);


                    fxptui.Plotter.compareRuns(sdiBaseline,sdiVerify,1);

                end

                if~isempty(errorMessage)
                    exception=MException(errorMessage.Identifier,errorMessage.getString);
                    throw(exception);
                end

            else
                scenarioResult=this.ScenarioResults(index);
                explore(scenarioResult);
            end

        end


        function value=get.RunName(this)

            if isempty(this.pRunName)

                ID=this.AutoscalerDesignResult.VerificationFPTID;
                value=this.getRunName(ID);

                this.pRunName=value;
            end

            value=this.pRunName;
        end

        function value=get.BaselineRunName(this)

            if isempty(this.pBaselineRunName)

                ID=this.AutoscalerDesignResult.BaselineFPTID;
                value=this.getRunName(ID);

                this.pBaselineRunName=value;
            end

            value=this.pBaselineRunName;
        end

        function value=get.Status(this)

            value=this.StatusCode.getString;
        end

        function value=get.MaxDifference(this)

            if this.StatusCode==fxptds.VerificationStatus.UnknownBaseline
                value=NaN;
            else
                value=this.AutoscalerDesignResult.MaxDifference;
            end
        end


        function value=get.ConstraintSettings(this)


            if this.StatusCode==fxptds.VerificationStatus.UnknownBaseline
                value=DataTypeWorkflow.ConstraintSettings;
            else
                value=this.AutoscalerDesignResult.ConstraintSettings;
            end
        end

        function value=get.StatusCode(this)

            if isempty(this.pStatusCode)
                value=this.AutoscalerDesignResult.VerificationStatus;

                this.pStatusCode=value;
            end

            value=this.pStatusCode;
        end

    end

    methods(Hidden)

        function s=toStruct(this)
            s=struct('Name','','Baseline','','Status','');
            s.Name=this.RunName;
            s.Baseline=this.BaselineRunName;
            s.Status=string(this.StatusCode);
        end

        function b=isValid(this)
            b=this.IsValid;
        end
    end

    methods(Access={?DataTypeWorkflowTestCase})

        function initialize(this)
            props=properties(this);
            for idx=1:numel(props)
                prop=props{idx};
                this.(prop);
            end


            for idx=1:numel(this.AutoscalerDesignResult.ScenarioReports)
                scenarioReport=this.AutoscalerDesignResult.ScenarioReports{idx};
                scenarioResult=DataTypeWorkflow.VerificationResult(scenarioReport);
                this.ScenarioResults(idx)=scenarioResult;
            end
        end

        function value=getRunName(this,ID)

            value='';

            model=this.AutoscalerDesignResult.TopModel;
            if~isempty(model)

                value=this.DataLayer.getRunNameFromID(model,ID);
            end



            if isempty(value)
                value=this.InvalidRun;
                this.IsValid=false;
            end

        end

    end

end

