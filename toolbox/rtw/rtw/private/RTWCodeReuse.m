function varargout=RTWCodeReuse(varargin)







    if(nargin>0)

        feature('RTWCodeReuse',varargin{1});
    else
        varargout{1}=feature('RTWCodeReuse');
    end
