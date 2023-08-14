function varargout=feature(varargin)


    featName=varargin{1};
    if(nargin==2)
        featVal=varargin{2};
        slfeature(featName,featVal);
    else
        varargout{1}=slfeature(featName);
    end
end
