function cb_overrideModeChanged(varargin)




    val=varargin{2}.Index;
    me=SigLogSelector.getExplorer;
    me.getRoot.setOverrideMode(val);

end
