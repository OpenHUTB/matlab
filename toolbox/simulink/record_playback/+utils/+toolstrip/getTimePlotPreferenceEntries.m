function prefEntry=getTimePlotPreferenceEntries(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:TickOutside')
        prefEntry='record_playback:toolstrip:TicksOutside';
    case DAStudio.message('record_playback:params:TickInside')
        prefEntry='record_playback:toolstrip:TicksInside';
    case DAStudio.message('record_playback:params:TickHide')
        prefEntry='record_playback:toolstrip:None';
    case DAStudio.message('record_playback:params:All')
        prefEntry='record_playback:toolstrip:TickLabelsAll';
    case DAStudio.message('record_playback:params:TimeAxis')
        prefEntry='record_playback:toolstrip:TimeAxis';
    case DAStudio.message('record_playback:params:YAxis')
        prefEntry='record_playback:toolstrip:TickLabelsYAxis';
    case DAStudio.message('record_playback:params:LegendTopLeft')
        prefEntry='record_playback:toolstrip:TicksLegendOutsideTop';
    case DAStudio.message('record_playback:params:LegendOutsideRight')
        prefEntry='record_playback:toolstrip:TicksLegendOutsideRight';
    case DAStudio.message('record_playback:params:LegendInsideLeft')
        prefEntry='record_playback:toolstrip:TicksLegendInsideTop';
    case DAStudio.message('record_playback:params:LegendInsideRight')
        prefEntry='record_playback:toolstrip:TicksLegendInsideRight';
    case DAStudio.message('record_playback:params:Wrap')
        prefEntry='record_playback:toolstrip:WrapMode';
    case DAStudio.message('record_playback:params:Scroll')
        prefEntry='record_playback:toolstrip:ScrollMode';
    otherwise
        prefEntry='record_playback:toolstrip:None';
    end
end