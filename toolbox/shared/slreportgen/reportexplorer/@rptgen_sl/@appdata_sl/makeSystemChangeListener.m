function mListen=makeSystemChangeListener(adsl,varargin)








    mListen=handle.listener(adsl,...
    adsl.findprop('CurrentSystem'),...
    'PropertyPostSet',...
    varargin{:});
