




classdef ConversionParametersForCheckOnlyMode<Simulink.ModelReference.Conversion.ConversionParameters
    methods(Access=public)
        function this=ConversionParametersForCheckOnlyMode(varargin)
            this@Simulink.ModelReference.Conversion.ConversionParameters(varargin{:});
        end
    end


    methods(Access=protected)
        function parseInputParameters(this,subsys)
            this.getSystemInfo(subsys);
            this.Force=true;
            this.ExportedFcn=false;
        end
    end
end
