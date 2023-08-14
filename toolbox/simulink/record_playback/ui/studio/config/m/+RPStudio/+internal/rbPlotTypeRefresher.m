function schema=rbPlotTypeRefresher(userData,cbinfo,action)


    if~strcmp(class(cbinfo.uiObject),"Simulink.Record")
        return;
    end

    schema=sl_action_schema;

    if~ismethod(cbinfo,'uiObject')...
        ||isempty(cbinfo.uiObject.Handle)||...
        ~isequal(cbinfo.uiObject.BlockType,'Record')
        return;
    end

    viewData=get_param(cbinfo.uiObject.Handle,'View');
    subPlots=viewData.subplots;
    subPlot=subPlots{int32(viewData.selectedPlotID)};
    plotType=subPlot.visual.visualName;
    switch(plotType)
    case DAStudio.message('record_playback:params:Sparkline')
        if strcmp(userData,'Sparkline')
            action.selected=1;
        end
        if strcmp(userData,'PlotTypeDropDown')
            action.text=slservices.StringOrID('record_playback:toolstrip:SparklinePlot');
            action.icon='rbSparkline';
        end
    case DAStudio.message('record_playback:params:TimePlot')
        if strcmp(userData,'Time')
            action.selected=1;
        end
        if strcmp(userData,'PlotTypeDropDown')
            action.text=slservices.StringOrID('record_playback:toolstrip:TimePlot');
            action.icon='rbTimePlot';
        end
    case DAStudio.message('record_playback:params:XY')
        if strcmp(userData,'XY')
            action.selected=1;
        end
        if strcmp(userData,'PlotTypeDropDown')
            action.text=slservices.StringOrID('record_playback:toolstrip:XYPlot');
            action.icon='rbXYPlot';
        end
    case DAStudio.message('record_playback:params:Map')
        if strcmp(userData,'Map')
            action.selected=1;
        end
        if strcmp(userData,'PlotTypeDropDown')
            action.text=slservices.StringOrID('record_playback:toolstrip:Map');
            action.icon='rbMapMarker';
        end
    case DAStudio.message('record_playback:params:TextEditor')
        if strcmp(userData,'TextEditor')
            action.selected=1;
        end
        if strcmp(userData,'PlotTypeDropDown')
            action.text=slservices.StringOrID('record_playback:toolstrip:TextEditor');
            action.icon='rbTextEditor';
        end
    case DAStudio.message('record_playback:params:Video')
        if strcmp(userData,'Video')
            action.selected=1;
        end
        if strcmp(userData,'PlotTypeDropDown')
            action.text=slservices.StringOrID('record_playback:toolstrip:Video');
            action.icon='videoPlot_24';
        end
    end
end