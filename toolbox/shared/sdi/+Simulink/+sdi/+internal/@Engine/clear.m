function clear(this,varargin)

    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});


    message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName',appName));
    tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',appName)));


    if strcmpi(appName,'sdi')
        appName='AllSDI';
    end


    tracker=Simulink.sdi.CancellableWork;
    tracker.MaxValue=10;
    tracker.IsModal=true;

    msgs.Message=getString(message('SDI:sdi:ClearProgressMsg'));
    msgs.KnownWork=false;
    msgs.Cancellable=false;
    tracker.setMessages(msgs);


    tracker.run(@(x)locClear(x,this,appName,varargin{:}));
end


function locClear(~,this,appName,varargin)
    this.deleteAllRuns(appName);
    this.sigRepository.purgeDeletedRuns(varargin{:});
    Simulink.AsyncQueue.DataType.clearCache();
    Simulink.sdi.internalSWSClear();
end
