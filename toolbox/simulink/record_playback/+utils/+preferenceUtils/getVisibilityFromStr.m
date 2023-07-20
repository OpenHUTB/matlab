function visibility=getVisibilityStr(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:Show')
        visibility=SdiVisual.Visibility.SHOW;
    otherwise
        visibility=SdiVisual.Visibility.HIDE;
    end
end