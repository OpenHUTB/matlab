function propertyList=getCCPropertyList




    propertyList=pm.sli.internal.ConfigsetProperty();
    propertyList(1).Name='SimscapeLogType';
    propertyList(1).IgnoreCompare=false;
    propertyList(1).Label='Log simulation data';
    propertyList(1).DataType='SSC_LOGGING_OPTIONS';
    propertyList(1).RowWithButton=false;



    propertyList(1).DisplayStrings={'None','All','Use local settings'};
    propertyList(1).Group='Data Logging';
    propertyList(1).GroupDesc='';
    propertyList(1).Visible=true;
    propertyList(1).Enabled=true;
    propertyList(1).DefaultValue='';
    propertyList(1).MatlabMethod='SSC.Logging.logTypePostSet';

    propertyList(1).Listener(1).Event={'PropertyPreSet'};
    propertyList(1).Listener(1).Callback=@lSimscapeLogTypePropPreSet;
    propertyList(1).Listener(1).CallbackTarget=@SSC.Logging;

    propertyList(1).Listener(2).Event={'PropertyPostSet'};
    propertyList(1).Listener(2).Callback=@lMarkModelDirty;
    propertyList(1).Listener(2).CallbackTarget=@SSC.Logging;

    propertyList(1).SetFcn=@(a,b)(b);

    propertyList(end+1).Name='SimscapeLogSimulationStatistics';
    propertyList(end).IgnoreCompare=false;
    propertyList(end).Label='Log simulation statistics';
    propertyList(end).DataType='slbool';
    propertyList(end).RowWithButton=false;



    propertyList(end).DisplayStrings={};
    propertyList(end).Group='Data Logging';
    propertyList(end).GroupDesc='';
    propertyList(end).Visible=true;
    propertyList(end).Enabled=@SSC.Logging.isLogNameEnabled;
    propertyList(end).DefaultValue='off';
    propertyList(end).MatlabMethod='';

    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.Logging;

    propertyList(end).SetFcn=@(a,b)(b);

    propertyList(end+1).Name='SimscapeLogToSDI';
    propertyList(end).IgnoreCompare=false;
    propertyList(end).Label='Record data in Simulation Data Inspector';
    propertyList(end).DataType='slbool';
    propertyList(end).RowWithButton=false;
    propertyList(end).DisplayStrings={};
    propertyList(end).Group='Data Logging';
    propertyList(end).GroupDesc='';
    propertyList(end).Visible=true;
    propertyList(end).Enabled=@SSC.Logging.isLogNameEnabled;
    propertyList(end).DefaultValue='off';
    propertyList(end).MatlabMethod='';
    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.Logging;
    propertyList(end).SetFcn=@(a,b)(b);

    propertyList(end+1).Name='SimscapeLogOpenViewer';
    propertyList(end).IgnoreCompare=false;
    propertyList(end).Label='Open viewer after simulation';
    propertyList(end).DataType='slbool';
    propertyList(end).RowWithButton=false;
    propertyList(end).DisplayStrings={};
    propertyList(end).Group='Data Logging';
    propertyList(end).GroupDesc='';
    propertyList(end).Visible=true;
    propertyList(end).Enabled=@SSC.Logging.isLogNameEnabled;
    propertyList(end).DefaultValue='off';
    propertyList(end).MatlabMethod='';

    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.Logging;

    propertyList(end).SetFcn=@(a,b)(b);

    propertyList(end+1).Name='SimscapeLogName';
    propertyList(end).IgnoreCompare=false;
    propertyList(end).Label='Workspace variable name';
    propertyList(end).DataType='string';
    propertyList(end).RowWithButton=false;



    propertyList(end).Group='Data Logging';
    propertyList(end).GroupDesc='';
    propertyList(end).Visible=true;
    propertyList(end).Enabled=@SSC.Logging.isLogNameEnabled;
    propertyList(end).DefaultValue=@lGetDefaultLogName;
    propertyList(end).MatlabMethod='';

    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.Logging;

    propertyList(end).SetFcn=@SSC.Logging.validateLogName;


    propertyList(end+1).Name='SimscapeLogDecimation';
    propertyList(end).IgnoreCompare=false;
    propertyList(end).Label='Decimation';
    propertyList(end).DataType='double';
    propertyList(end).RowWithButton=false;



    propertyList(end).Group='Data Logging';
    propertyList(end).GroupDesc='';
    propertyList(end).Visible=true;
    propertyList(end).Enabled=@SSC.Logging.isLogNameEnabled;
    propertyList(end).DefaultValue=1;
    propertyList(end).MatlabMethod='';

    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.Logging;

    propertyList(end).SetFcn=@SSC.Logging.validateLogDecimation;

    propertyList(end+1).Name='SimscapeLogLimitData';
    propertyList(end).IgnoreCompare=false;
    propertyList(end).Label='Limit data points';
    propertyList(end).DataType='slbool';
    propertyList(end).RowWithButton=false;



    propertyList(end).Group='Data Logging';
    propertyList(end).GroupDesc='';
    propertyList(end).Visible=true;
    propertyList(end).Enabled=@SSC.Logging.isLogNameEnabled;
    propertyList(end).DefaultValue='on';
    propertyList(end).MatlabMethod='SSC.Logging.logLimitPostSet';

    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.Logging;

    propertyList(end).SetFcn=@(a,b)(b);

    propertyList(end+1).Name='SimscapeLogDataHistory';
    propertyList(end).IgnoreCompare=false;
    propertyList(end).Label='Data history (last N steps)';
    propertyList(end).DataType='double';
    propertyList(end).RowWithButton=false;



    propertyList(end).Group='Data Logging';
    propertyList(end).GroupDesc='';
    propertyList(end).Visible=true;
    propertyList(end).Enabled=@SSC.Logging.isLogDataHistoryEnabled;
    propertyList(end).DefaultValue=5000;
    propertyList(end).MatlabMethod='';

    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.Logging;

    propertyList(end).SetFcn=@SSC.Logging.validateLogDataHistory;

end

function lMarkModelDirty(~,eventData)


    owner=eventData.AffectedObject;
    event=eventData.Type;
    switch event
    case 'PropertyPostSet'
        dirtyModel=pmsl_private('pmsl_markmodeldirty');
        dirtyModel(owner.getBlockDiagram);
    otherwise
        pm_assert(0,'unsupported callback in propertyCallback_errorOptions');
    end
end

function name=lGetDefaultLogName(source,~)%#ok


    name='simlog';
end


function lSimscapeLogTypePropPreSet(~,eventData)

    if(strcmp(eventData.newValue,'Use local settings'))
        eventData.newValue='local';
    elseif(strcmp(eventData.newValue,'All'))
        eventData.newValue='all';
    elseif(strcmp(eventData.newValue,'None'))
        eventData.newValue='none';
    end
end


