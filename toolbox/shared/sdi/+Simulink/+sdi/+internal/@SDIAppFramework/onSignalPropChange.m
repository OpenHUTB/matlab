function onSignalPropChange(this,varargin)
    assert(length(varargin)==3);
    propName=varargin{1};
    id=varargin{2};
    value=varargin{3};
    evtType='treeSignalPropertyEvent';


    notify(...
    this.Engine_,...
    evtType,...
    Simulink.sdi.internal.SDIEvent(evtType,id,value,propName));


    this.Engine_.dirty=true;


    switch propName
    case{'signalLabel'}
        Simulink.sdi.SignalClient.publishSignalLabels(id);
    case{'units','displayUnits','displayScaling','displayOffset'}
        Simulink.sdi.WebClient.refreshSignalUnits(id);
    case{'dataType'}
        Simulink.sdi.WebClient.refreshDataType(id);
    case{'complexFormat'}
        Simulink.sdi.redrawSignalAfterRescale(id);
    case{'linestyle','color','marker','linewidth'}
        clr=this.Engine_.getSignalLine(id);
        evtType='propertyChangeEvent';
        notify(...
        this.Engine_,...
        evtType,...
        Simulink.sdi.internal.SDIEvent(evtType,id,Simulink.sdi.internal.StringDict.mgLine,clr));
    case{'abs'}
        evtType='propertyChangeEvent';
        notify(...
        this.Engine_,...
        evtType,...
        Simulink.sdi.internal.SDIEvent(evtType,id,Simulink.sdi.internal.StringDict.mgAbsTol,value));
    case{'rel'}
        evtType='propertyChangeEvent';
        notify(...
        this.Engine_,...
        evtType,...
        Simulink.sdi.internal.SDIEvent(evtType,id,Simulink.sdi.internal.StringDict.mgRelTol,value));
    case{'sync'}
        evtType='propertyChangeEvent';
        notify(...
        this.Engine_,...
        evtType,...
        Simulink.sdi.internal.SDIEvent(evtType,id,Simulink.sdi.internal.StringDict.mgSyncMethod,value));
    case{'interp'}
        evtType='propertyChangeEvent';
        notify(...
        this.Engine_,...
        evtType,...
        Simulink.sdi.internal.SDIEvent(evtType,id,Simulink.sdi.internal.StringDict.mgInterpMethod,value));
        Simulink.sdi.WebClient.refreshInterpolation(id);
    otherwise
    end
end
