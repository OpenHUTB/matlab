function grid=getGridDisplayFromStr(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:None')
        grid=SdiVisual.GridDisplay.GRID_HIDE;
    case DAStudio.message('record_playback:params:Horizontal')
        grid=SdiVisual.GridDisplay.HORIZONTAL_ONLY;
    case DAStudio.message('record_playback:params:Vertical')
        grid=SdiVisual.GridDisplay.VERTICAL_ONLY;
    otherwise
        grid=SdiVisual.GridDisplay.GRID_SHOW;
    end
end