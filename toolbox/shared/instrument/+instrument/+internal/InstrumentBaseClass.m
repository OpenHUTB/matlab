classdef(HandleCompatible)InstrumentBaseClass








    methods(Hidden)
        function obj=InstrumentBaseClass(varargin)
            switch nargin
            case 0
                instrument.internal.InstrumentBaseClass.attemptLicenseCheckout();
            case 1


                if~strcmpi(varargin{1},'serial')
                    instrument.internal.InstrumentBaseClass.attemptLicenseCheckout();
                end
            end
        end
    end

    methods(Hidden,Static)
        function attemptLicenseCheckout()

            try
                matlab.internal.licensing.checkoutProductLicense("IC");
            catch
                error(message('instrument:general:notlicensed'));
            end
        end
    end

end