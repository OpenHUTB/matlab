function varargout=Three_PhaseV_IMeasuremen(varargin)



    varargin=varargin{:};
    [~,blockName,~]=fileparts(mfilename('fullpath'));
    out=ee.internal.assistant.utils.mapFunc(blockName,varargin);
    varargout={out};

end
