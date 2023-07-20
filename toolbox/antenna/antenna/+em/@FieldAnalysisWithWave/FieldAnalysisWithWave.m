classdef(Abstract)FieldAnalysisWithWave<handle

    methods
        varargout=rcs(obj,freq,varargin)
    end

    methods(Access=protected)

        [parseobj,azimuth,elevation,azimuthTx,elevationTx,txrxangflag]...
        =rcspatternparser(obj,freq,varargin,nargout);

    end
end

