function[varargout]=SkipFPGAProgFile(varargin)
    persistent value
    if nargin==0
        if isempty(value)
            varargout{1}=false;
        else
            varargout{1}=value;
        end
    else
        value=varargin{1};
    end
end


