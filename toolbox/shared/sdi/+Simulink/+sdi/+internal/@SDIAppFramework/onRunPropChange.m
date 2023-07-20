function onRunPropChange(this,varargin)
    assert(length(varargin)==3);
    propName=varargin{1};
    id=varargin{2};
    value=varargin{3};
    evtType='treeRunPropertyEvent';


    notify(...
    this.Engine_,...
    evtType,...
    Simulink.sdi.internal.SDIEvent(evtType,id,value,propName));


    this.Engine_.dirty=true;


    switch propName
    case{'runName'}
        sigIDs=this.Engine_.getAllSignalIDs(id,'leaf');
        Simulink.sdi.SignalClient.publishSignalLabels(sigIDs);
    case{'runDescription'}
        evtType='propertyChangeEvent';
        notify(...
        this.Engine_,...
        evtType,...
        Simulink.sdi.internal.SDIEvent(evtType,id,Simulink.sdi.internal.StringDict.mgDescription,value));
    otherwise
    end
end
