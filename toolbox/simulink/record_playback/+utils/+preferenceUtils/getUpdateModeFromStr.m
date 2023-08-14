function mode=getUpdateModeFromStr(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:Wrap')
        mode=SdiVisual.UpdateMode.WRAP;
    otherwise
        mode=SdiVisual.UpdateMode.SCROLL;
    end
end