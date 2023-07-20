classdef satAmp<serdes.SaturatingAmplifier&serdes.internal.serdesquicksimulation.SERDESElement




    methods
        function obj=satAmp(varargin)
            obj@serdes.internal.serdesquicksimulation.SERDESElement(varargin{:});
        end
    end

    properties(Constant,Access=protected)
        HeaderDescription=getString(message('serdes:serdesdesigner:SatAmpHdrDesc'));
    end
    properties(Constant,Hidden)
        DefaultName='SatAmp';
    end

    methods(Hidden,Access=protected)
        function out=localClone(in)
            out=serdes.internal.apps.serdesdesigner.satAmp;
            copyProperties(in,out)
        end
    end
end
