function onSignalAdded(this,varargin)
    assert(length(varargin)==1);
    id=varargin{1};


    USE_PROGRESS_TRACKER=true;
    evtType='signalsInsertedEvent';
    notify(...
    this.Engine_,...
    evtType,...
    Simulink.sdi.internal.SDIEvent(evtType,id,USE_PROGRESS_TRACKER));


    this.Engine_.dirty=true;
end
