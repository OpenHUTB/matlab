function varargout=matlabcoder(varargin)










    try
        if nargout>0
            [varargout{1:nargout}]=coder(varargin{:});
        else
            coder(varargin{:});
        end
    catch me
        me.throwAsCaller();
    end
