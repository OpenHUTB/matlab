function UD=remove_selection_display_line(UD)




    if isempty(UD.current.selectLine)
        return;
    end
    if ishghandle(UD.current.selectLine,'line')
        delete(UD.current.selectLine)
        UD.current.selectLine=[];
    end
