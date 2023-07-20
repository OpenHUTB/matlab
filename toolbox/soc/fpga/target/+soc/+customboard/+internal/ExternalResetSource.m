classdef ExternalResetSource<soc.customboard.internal.ExternalIOInterface

    methods
        function obj=ExternalResetSource(varargin)
            name=varargin{1};
            pins=varargin{2};
            pad=varargin{3};
            if nargin==4
                polarity=varargin{4};
            else
                polarity='active_high';
            end
            obj@soc.customboard.internal.ExternalIOInterface(...
            'ExternalResetSource',name,1,pins,pad,polarity);
        end
    end
end