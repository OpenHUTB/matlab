function verifyAxisLimits(min,max,blkHdl,subPlotId)
    row=[];
    col=[];
    bp=[];
    if isnan(min)||isnan(max)||min>max
        if strcmp(get_param(blkHdl,'BlockType'),'Playback')
            row=1;
            col=1;
        else
            layout=utils.recordDialogUtils.getGridFromLayout(blkHdl);
            if~isempty(layout)||strcmp(layout,DAStudio.message('record_playback:params:Auto'))
                col=int32(subPlotId/9)+1;
                row=subPlotId-(col-1)*8;
            end
        end
        bp=getfullname(blkHdl);
    else
        return;
    end

    if isnan(min)||isnan(max)
        if isempty(row)
            throwAsCaller(MException('record_playback:errors:InvalidSubplotNumericEntry',...
            DAStudio.message('record_playback:errors:InvalidSubplotNumericEntry',bp)));
        else
            throwAsCaller(MException('record_playback:errors:InvalidRowColNumericEntry',...
            DAStudio.message('record_playback:errors:InvalidRowColNumericEntry',row,col,bp)));
        end
    end

    if(min>max)
        if isempty(row)
            throwAsCaller(MException('record_playback:errors:InvalidSubplotLimits',...
            DAStudio.message('record_playback:errors:InvalidSubplotLimits',bp)));
        else
            throwAsCaller(MException('record_playback:errors:InvalidRowColLimits',...
            DAStudio.message('record_playback:errors:InvalidRowColLimits',row,col,bp)));
        end
    end
end
