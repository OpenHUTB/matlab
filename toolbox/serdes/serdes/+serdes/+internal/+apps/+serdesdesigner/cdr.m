classdef cdr<serdes.CDR&serdes.internal.serdesquicksimulation.SERDESElement




    methods
        function obj=cdr(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:CdrHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='CDR';
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.cdr;
            copyProperties(in,out)
        end
    end
end
