




classdef GuiParametersForDataDictionary<Simulink.ModelReference.Conversion.GuiParameters
    methods(Access=public)
        function this=GuiParametersForDataDictionary(mdladvObj,modelName)
            this@Simulink.ModelReference.Conversion.GuiParameters(mdladvObj,modelName);

        end
    end


    methods(Access=protected)
        function updateParameters(this)




            this.InputParameters{Simulink.ModelReference.Conversion.GuiParameters.DataFile}.Enable=false;
        end
    end
end
