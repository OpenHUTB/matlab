classdef transparent<serdes.PassThrough&serdes.internal.serdesquicksimulation.SERDESElement



    methods
        function obj=transparent(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:TransparentHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='PT';
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.transparent;
            copyProperties(in,out)
        end
    end
end
