function cssd=getConfigSetStaticData(varargin)

    if nargin==0
        cssd=configset.internal.data.MetaConfigSet.getInstance();
    else
        cssd=configset.internal.data.MetaConfigSet.getInstance(varargin{1});
    end
