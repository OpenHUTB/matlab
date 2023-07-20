classdef CheckModelForConversionRCB<Simulink.ModelReference.Conversion.CheckModelForConversion
    methods(Access=protected)
        function results=checkMdlSettings(this)

            results=this.checkTunableParameters;
        end
    end
end