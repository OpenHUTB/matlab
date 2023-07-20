function openSession(this,sessionFullPath)











    try
        vars=load(sessionFullPath);
    catch ME
        this.errorDlg('slrealtime:appdesigner:OpenSessionError',ME.message);
        return;
    end



    prev.SessionSavedToFile=this.SessionSavedToFile;
    prev.Dirty=this.Dirty;
    prev.SessionSource=this.SessionSource;
    prev.Options.OptionsToolstripItem=this.OptionsToolstripItem.Value;
    prev.Options.OptionsMenuItem=this.OptionsMenuItem.Value;
    prev.Options.OptionsStatusBarItem=this.OptionsStatusBarItem.Value;
    prev.Options.OptionsTETMonitorItem=this.OptionsTETMonitorItem.Value;
    prev.Options.OptionsInstrumentedSignalsItem=this.OptionsInstrumentedSignalsItem.Value;
    prev.Options.OptionsDashboardItem=this.OptionsDashboardItem.Value;
    prev.Options.OptionsUseGridItem=this.OptionsUseGridItem.Value;
    prev.Options.OptionsCallbackItem=this.OptionsCallbackItem.Value;
    prev.TreeConfigureSignals=this.TreeConfigureSignals.Value;
    prev.TreeConfigureParameters=this.TreeConfigureParameters.Value;
    prev.BindingData=this.BindingData;
    prev.BindingTableData=this.BindingTable.Data;


    prev.Props.TargetSelector=this.savePropValues(this.PropsTargetSelector);
    prev.Props.ConnectButton=this.savePropValues(this.PropsConnectButton);
    prev.Props.LoadButton=this.savePropValues(this.PropsLoadButton);
    prev.Props.StartStopButton=this.savePropValues(this.PropsStartStopButton);
    prev.Props.StopTime=this.savePropValues(this.PropsStopTime);
    prev.Props.SystemLog=this.savePropValues(this.PropsSystemLog);
    prev.Props.StatusBar=this.savePropValues(this.PropsStatusBar);
    prev.Props.Menu=this.savePropValues(this.PropsMenu);
    prev.Props.Map=containers.Map('KeyType','char','ValueType','any');
    keys=this.PropsMap.keys;
    values=this.PropsMap.values;
    for i=1:numel(values)
        prev.Props.Map(keys{i})=values{i};
    end



    this.revertSessionToDefaults();



    try





        if~exist(vars.data.SessionSource.SourceFile)%#ok
            [~,file,ext]=fileparts(vars.data.SessionSource.SourceFile);
            fileWithExt=[file,ext];
            fullpath=which(fileWithExt);
            if isempty(fullpath)
                slrealtime.internal.throw.Error('MATLAB:open:fileNotFound',fileWithExt);
            end
            vars.data.SessionSource.SourceFile=fullpath;
        end

        this.newSession(vars.data.SessionSource.SourceFile);
        this.OptionsToolstripItem.Value=vars.data.Options.OptionsToolstripItem;
        this.OptionsMenuItem.Value=vars.data.Options.OptionsMenuItem;
        this.OptionsStatusBarItem.Value=vars.data.Options.OptionsStatusBarItem;
        this.OptionsTETMonitorItem.Value=vars.data.Options.OptionsTETMonitorItem;
        this.OptionsInstrumentedSignalsItem.Value=vars.data.Options.OptionsInstrumentedSignalsItem;
        this.OptionsDashboardItem.Value=vars.data.Options.OptionsDashboardItem;
        if isfield(vars.data.Options,'OptionsUseGridItem')
            this.OptionsUseGridItem.Value=vars.data.Options.OptionsUseGridItem;
        else
            this.OptionsUseGridItem.Value=this.OptionsUseGridItemDefaultValue;
        end
        this.OptionsCallbackItem.Value=vars.data.Options.OptionsCallbackItem;
        this.TreeConfigureSignals.Value=vars.data.TreeConfig.ConfigSignals;
        this.TreeConfigureParameters.Value=vars.data.TreeConfig.ConfigParameters;
        this.BindingData=vars.data.BindingData;
        this.BindingTable.Data=vars.data.BindingTableData;

        if isfield(vars.data,'Props')

            this.copyPropValues(vars.data.Props.TargetSelector,this.PropsTargetSelector);
            this.copyPropValues(vars.data.Props.ConnectButton,this.PropsConnectButton);
            this.copyPropValues(vars.data.Props.LoadButton,this.PropsLoadButton);
            this.copyPropValues(vars.data.Props.StartStopButton,this.PropsStartStopButton);
            this.copyPropValues(vars.data.Props.StopTime,this.PropsStopTime);
            this.copyPropValues(vars.data.Props.SystemLog,this.PropsSystemLog);
            this.copyPropValues(vars.data.Props.StatusBar,this.PropsStatusBar);
            this.copyPropValues(vars.data.Props.Menu,this.PropsMenu);
            if isfield(vars.data.Props,'Map')&&~isempty(vars.data.Props.Map)
                keys=fields(vars.data.Props.Map);
                for i=1:numel(keys)
                    this.createComponentForPropsMap(keys{i},vars.data.Props.Map.(keys{i}).Type);
                    this.copyPropValues(vars.data.Props.Map.(keys{i}),this.PropsMap(keys{i}));
                end
            end
        else
            for i=1:numel(this.BindingData)
                this.createComponentForPropsMap(this.BindingData{i}.ControlName,this.BindingData{i}.ControlType);
            end
        end

        for i=1:numel(this.BindingData)

            this.BindingData{i}.Valid=true;



            if~this.isBindingParameter(i)
                this.BindingData{i}.UseName=true;
            end
        end

        this.refreshStyles();

        this.SessionSavedToFile=sessionFullPath;
        this.Dirty=false;

    catch ME


        this.revertSessionToDefaults();

        this.SessionSavedToFile=prev.SessionSavedToFile;
        this.Dirty=prev.Dirty;
        if~isempty(prev.SessionSource)
            this.newSession(prev.SessionSource.SourceFile);
        end
        this.OptionsToolstripItem.Value=prev.Options.OptionsToolstripItem;
        this.OptionsMenuItem.Value=prev.Options.OptionsMenuItem;
        this.OptionsStatusBarItem.Value=prev.Options.OptionsStatusBarItem;
        this.OptionsTETMonitorItem.Value=prev.Options.OptionsTETMonitorItem;
        this.OptionsInstrumentedSignalsItem.Value=prev.Options.OptionsInstrumentedSignalsItem;
        this.OptionsDashboardItem.Value=prev.Options.OptionsDashboardItem;
        this.OptionsUseGridItem.Value=prev.Options.OptionsUseGridItem;
        this.OptionsCallbackItem.Value=prev.Options.OptionsCallbackItem;
        this.TreeConfigureSignals.Value=prev.TreeConfigureSignals;
        this.TreeConfigureParameters.Value=prev.TreeConfigureParameters;
        this.BindingData=prev.BindingData;
        this.BindingTable.Data=prev.BindingTableData;

        this.copyPropValues(prev.Props.TargetSelector,this.PropsTargetSelector);
        this.copyPropValues(prev.Props.ConnectButton,this.PropsConnectButton);
        this.copyPropValues(prev.Props.LoadButton,this.PropsLoadButton);
        this.copyPropValues(prev.Props.StartStopButton,this.PropsStartStopButton);
        this.copyPropValues(prev.Props.StopTime,this.PropsStopTime);
        this.copyPropValues(prev.Props.SystemLog,this.PropsSystemLog);
        this.copyPropValues(prev.Props.StatusBar,this.PropsStatusBar);
        this.copyPropValues(prev.Props.Menu,this.PropsMenu);
        keys=prev.Props.Map.keys;
        values=prev.Props.Map.values;
        for i=1:numel(values)
            this.PropsMap(keys{i})=values{i};
        end

        this.refreshStyles();

        this.errorDlg('slrealtime:appdesigner:OpenSessionError',ME.message);
        return;
    end
end
