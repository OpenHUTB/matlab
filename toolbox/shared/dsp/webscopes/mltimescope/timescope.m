classdef timescope<dsp.webscopes.TimePlotBaseWebScope















































































%#function utils.getDefaultWebWindowPosition
%#function utils.logicalToOnOff

    methods
        function obj=timescope(varargin)

            product=dsp.webscopes.TimePlotBaseWebScope.licenseCheckout(true);

            obj@dsp.webscopes.TimePlotBaseWebScope('Product',product,varargin{:});
        end
    end
end
