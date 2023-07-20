function varargout=Mean_Phasor_(varargin)



    varargin=varargin{:};
    [~,blockName,~]=fileparts(mfilename('fullpath'));
    out=ee.internal.assistant.utils.mapFunc(blockName,varargin);
    varargout={out};

end
