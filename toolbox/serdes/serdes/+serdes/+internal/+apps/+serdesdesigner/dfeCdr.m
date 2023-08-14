classdef dfeCdr<serdes.DFECDR&serdes.internal.serdesquicksimulation.SERDESElement




    methods
        function obj=dfeCdr(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:DfeCdrHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='DFECDR';
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.dfeCdr;
            copyProperties(in,out)
        end
    end
end
