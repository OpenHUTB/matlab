classdef Checker<handle




    properties
ConversionParameters
Logger
    end
    methods(Access=public)
        function this=Checker(ConversionParameters,Logger)
            this.ConversionParameters=ConversionParameters;
            this.Logger=Logger;
        end
    end
    methods(Access=protected)
        function handleDiagnostic(this,msg)
            if(this.ConversionParameters.Force)
                this.Logger.addWarning(msg);
            else
                throw(MSLException(msg));
            end
        end
    end
end
