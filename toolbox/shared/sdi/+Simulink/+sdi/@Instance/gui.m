function sdiGUI=gui(varargin)
    sdiGUI=Simulink.sdi.Instance.getSetGUI();
    Simulink.sdi.Instance.getSetGUIOpenningFlag(true);
    isQuery=(nargin==1&&ischar(varargin{1}));
    if~isQuery&&(isempty(sdiGUI)||~isRunning(sdiGUI))
        SDIEngine=Simulink.sdi.Instance.engine();
        sdiGUI=Simulink.sdi.internal.WebGUI(SDIEngine,varargin{:});
        Simulink.sdi.Instance.getSetGUI(sdiGUI);
    end
    Simulink.sdi.Instance.getSetGUIOpenningFlag(false);
end
