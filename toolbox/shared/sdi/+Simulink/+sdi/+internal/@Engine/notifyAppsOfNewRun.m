function notifyAppsOfNewRun(this,varargin)




    notify(this,'runAddedEvent',Simulink.sdi.internal.SDIEvent('runAddedEvent',varargin{:}));
end
