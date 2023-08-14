classdef ChangeTopModelSimulationMode<Simulink.ModelReference.Conversion.ModificationObject
    properties(SetAccess=private,GetAccess=private)
ModelName
SimulationMode
    end

    methods(Access=public)
        function this=ChangeTopModelSimulationMode(modelName,simMode)
            this.ModelName=modelName;
            this.SimulationMode=simMode;
            beautifiedModelName=Simulink.ModelReference.Conversion.MessageBeautifier.beautifyModelName(this.ModelName);
            this.Description=DAStudio.message('Simulink:modelReferenceAdvisor:ModifyTopModelSimulationMode',beautifiedModelName,simMode);
        end

        function exec(this)
            set_param(this.ModelName,'SimulationMode',this.SimulationMode);
        end
    end
end
