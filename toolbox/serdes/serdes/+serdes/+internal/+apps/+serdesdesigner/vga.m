classdef vga<serdes.VGA&serdes.internal.serdesquicksimulation.SERDESElement




    methods
        function obj=vga(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:VgaHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='VGA';
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.vga;
            copyProperties(in,out)
        end
    end
end
