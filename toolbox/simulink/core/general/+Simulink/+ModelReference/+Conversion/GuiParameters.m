




classdef GuiParameters<handle
    properties(Access=protected)
ModelName
InputParameters
SuggestedName
ModelReferenceAdvisor
    end


    properties(Constant)
        NewModel=1;
        DataFile=2;
        AutoFix=3;
        ReplaceSubsystem=4;
        CopyCodeMappings=5;
        SimulationMode=6;
        CheckSimulationResults=7;
        StopTime=8;
        AbsoluteTolerance=9;
        RelativeTolerance=10;
    end


    methods(Static,Access=public)
        function obj=getGuiParameters(mdladvObj,modelName)
            if isempty(get_param(modelName,'DataDictionary'))
                obj=Simulink.ModelReference.Conversion.GuiParametersForBaseWorkspace(mdladvObj,modelName);
            else
                obj=Simulink.ModelReference.Conversion.GuiParametersForDataDictionary(mdladvObj,modelName);
            end
        end
    end


    methods(Access=public)
        function this=GuiParameters(mdladvObj,modelName)
            this.ModelReferenceAdvisor=mdladvObj;
            this.ModelName=modelName;
        end

        function update(this)
            if isfield(this.ModelReferenceAdvisor.UserData,'ModelRefAdvisor')
                userData=this.ModelReferenceAdvisor.UserData.ModelRefAdvisor;
                subsys=getfullname(userData.Systems);
                this.updateDefaultInputParameters(this.ModelReferenceAdvisor,subsys);
                this.updateParameters;
                Simulink.ModelReference.Conversion.GuiParameters.updateTextsWithSubsystemName(this.ModelReferenceAdvisor,subsys);
            end
        end
    end


    methods(Abstract,Access=protected)
        updateParameters(this);
    end


    methods(Static,Access=private)
        function updateTextsWithSubsystemName(mdladvObj,subsys)
            checkObj=mdladvObj.getCheckObj(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorInputParametersId);
            checkObj.TitleTips=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorInputParametersAnalysis',subsys);
        end
    end


    methods(Access=private)
        function updateDefaultInputParameters(this,mdladvObj,subsys)
            taskObj=mdladvObj.getTaskObj(Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorMainGroupId);
            this.InputParameters=taskObj.getInputParameters;


            taskObj.DisplayName=subsys;
            taskObj.Description=DAStudio.message('Simulink:modelReferenceAdvisor:AdvisorMainGroupAnalysis',subsys);


            nameObj=Simulink.ModelReference.Conversion.NameUtils;
            this.SuggestedName=nameObj.getValidModelName(subsys);
            this.InputParameters{Simulink.ModelReference.Conversion.GuiParameters.NewModel}.Value=this.SuggestedName;


            dataFileName=Simulink.ModelReference.Conversion.ConversionParameters.getDataFileName(this.ModelName);
            this.InputParameters{Simulink.ModelReference.Conversion.GuiParameters.DataFile}.Value=dataFileName;


            stopTime=get_param(this.ModelName,'StopTime');
            this.InputParameters{Simulink.ModelReference.Conversion.GuiParameters.StopTime}.Value=stopTime;

            absError=Simulink.SDIInterface.calculateDefaultAbsoluteTolerance(this.ModelName);
            this.InputParameters{Simulink.ModelReference.Conversion.GuiParameters.AbsoluteTolerance}.Value=num2str(absError);

            relError=Simulink.SDIInterface.calculateDefaultRelativeTolerance(this.ModelName);
            this.InputParameters{Simulink.ModelReference.Conversion.GuiParameters.RelativeTolerance}.Value=num2str(relError);
        end
    end
end
