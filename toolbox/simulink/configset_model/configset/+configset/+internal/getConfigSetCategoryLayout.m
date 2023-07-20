function cssl=getConfigSetCategoryLayout(varargin)

    if nargin==0
        cssl=configset.layout.MetaConfigLayout.getInstance();
    else
        cssl=configset.layout.MetaConfigLayout.getInstance(varargin{1});
    end

