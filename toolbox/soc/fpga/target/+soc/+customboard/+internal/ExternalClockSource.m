classdef ExternalClockSource<soc.customboard.internal.ExternalIOInterface

    properties(SetAccess=private)
Frequency


    end

    methods
        function obj=ExternalClockSource(varargin)
            name=varargin{1};
            pins=varargin{2};
            pad=varargin{3};
            freq=varargin{4};

            obj@soc.customboard.internal.ExternalIOInterface('ExternalClockSource',name,1,pins,pad);
            obj.Frequency=freq;
        end
    end

end