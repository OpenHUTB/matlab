function mListen=makeModelChangeListener(adsl,varargin)








    mListen=handle.listener(adsl,...
    adsl.findprop('CurrentModel'),...
    'PropertyPostSet',...
    varargin{:});
