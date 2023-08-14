function dataTipRows=createDefaultDataTipRows(hObj)






















    if strcmpi(hObj.BarLayout,'grouped')

        dataTipRows=[dataTipTextRow('X','XData');...
        dataTipTextRow('Y','YData')];
    else
        if strcmpi(hObj.Horizontal,'on')

            dataTipRows=[dataTipTextRow('X (Stacked)','X (Stacked)');...
            dataTipTextRow('X (Segment)','X (Segment)');...
            dataTipTextRow('Y','YData')];
        else

            dataTipRows=[dataTipTextRow('X','XData');...
            dataTipTextRow('Y (Stacked)','Y (Stacked)');...
            dataTipTextRow('Y (Segment)','Y (Segment)')];
        end
    end