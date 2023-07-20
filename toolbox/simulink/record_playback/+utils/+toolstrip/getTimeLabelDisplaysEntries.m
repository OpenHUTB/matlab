function prefEntry=getTimeLabelDisplaysEntries(entryValue)
    switch entryValue
    case DAStudio.message('record_playback:params:ShowLastSparkline')
        prefEntry='record_playback:toolstrip:SparklineLastLabel';
    otherwise
        prefEntry='record_playback:toolstrip:SparklineAllLabels';
    end
end