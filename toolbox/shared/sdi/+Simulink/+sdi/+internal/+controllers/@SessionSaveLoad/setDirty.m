function setDirty(this,varargin)
    dirtyFlag=varargin{1};
    bUseQ=false;
    if nargin>2
        bUseQ=varargin{2};
    end
    Simulink.sdi.setDirtyFlag(this.AppName,dirtyFlag,bUseQ);
end