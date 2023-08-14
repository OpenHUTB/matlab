




classdef ConversionParametersForGUI<Simulink.ModelReference.Conversion.ConversionParameters
    methods(Access=public)
        function this=ConversionParametersForGUI(varargin)
            this@Simulink.ModelReference.Conversion.ConversionParameters(varargin{:});
        end
    end


    methods(Access=protected)
        function parseInputParameters(this,varargin)
            this.getSystemInfo(varargin{1});
            name=varargin{2};
            val=varargin{3};
            if strcmp(name,'UseConversionAdvisor')
                if islogical(val)
                    if~val
                        throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidInputArgument_UseConversionAdvisor')));
                    end
                    this.UseConversionAdvisor=val;
                else
                    throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidInputArgument',name)));
                end
            else
                throw(MException(message('Simulink:modelReference:convertToModelReference_InvalidInputArgument',name)));
            end
        end
    end
end
