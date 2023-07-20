function out=getSyncOptions(this,varargin)
    [~,out]=this.defaultTolAndSyncOptions();
    if nargin>2
        id=this.getSignalIDByIndex(varargin{:});
    else
        id=varargin{1};
    end

    out.SyncMethod=this.getSignalSyncMethod(id);
    out.InterpMethod=this.getSignalInterpMethod(id);
end