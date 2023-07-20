function varargout=currentObj(varargin)








    persistent currentObj;
    mlock;

    if isempty(varargin)
        varargout{1}=currentObj;
    else
        currentObj=varargin{1};
    end
end
