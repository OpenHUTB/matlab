function varargout=getSetIsStrictErrorHandling(varargin)




    persistent isStrict;
    if isempty(isStrict)
        isStrict=false;
    end

    if nargout>0
        varargout{1}=isStrict;
    end

    if nargin>0
        isStrict=varargin{1};
    end

end
