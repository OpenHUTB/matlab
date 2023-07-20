classdef agc<serdes.AGC&serdes.internal.serdesquicksimulation.SERDESElement



    methods
        function obj=agc(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:AgcHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='AGC';
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.agc;
            copyProperties(in,out)
        end
    end
end
