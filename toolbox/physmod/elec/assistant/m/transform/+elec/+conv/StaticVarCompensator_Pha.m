function varargout=StaticVarCompensator_Pha(varargin)



    varargin=varargin{:};
    [~,blockName,~]=fileparts(mfilename('fullpath'));
    out=ee.internal.assistant.utils.mapFunc(blockName,varargin);
    varargout={out};

end
