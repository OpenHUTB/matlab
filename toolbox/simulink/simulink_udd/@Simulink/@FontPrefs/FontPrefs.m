function this=FontPrefs(bdhandle)














    this=Simulink.FontPrefs;
    if ischar(bdhandle)
        bdhandle=get_param(bdhandle,'Handle');
    end
    assert(bdhandle~=0,'Not valid to use this class for Simulink.Root');
    this.SimulinkHandle=bdhandle;
end
