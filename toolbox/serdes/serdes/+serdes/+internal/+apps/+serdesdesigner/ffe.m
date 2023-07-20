classdef ffe<serdes.FFE&serdes.internal.serdesquicksimulation.SERDESElement




    methods
        function obj=ffe(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:FfeHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='FFE';
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.ffe;
            copyProperties(in,out)
        end
    end
end
