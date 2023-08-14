function cacheSessionInfo(this,varargin)


    if nargin>3
        dirty=varargin{3};
        Simulink.sdi.setDirtyFlag(this.AppName,dirty);
    end
    if nargin>2
        this.PathName=varargin{2};
    end
    if nargin>1
        this.FileName=varargin{1};
    end
    [title,titleDirty]=this.getTitle();
    this.Dirty=Simulink.sdi.cacheSessionInfo(this.AppName,title,titleDirty,this.FileName);
end
