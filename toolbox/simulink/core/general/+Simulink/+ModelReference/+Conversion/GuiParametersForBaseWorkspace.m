




classdef GuiParametersForBaseWorkspace<Simulink.ModelReference.Conversion.GuiParameters
    methods(Access=public)
        function this=GuiParametersForBaseWorkspace(mdladvObj,modelName)
            this@Simulink.ModelReference.Conversion.GuiParameters(mdladvObj,modelName);
        end
    end


    methods(Access=protected)
        function updateParameters(this)
            dataFile=Simulink.ModelReference.Conversion.ConversionParameters.getDataFileName(this.ModelName);
            this.InputParameters{Simulink.ModelReference.Conversion.GuiParameters.DataFile}.Value=...
            Simulink.ModelReference.Conversion.FileUtils.getUniqueFileName(dataFile);
        end
    end
end
