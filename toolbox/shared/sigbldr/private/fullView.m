function UD=fullView(dialog,UD)




    UD=set_new_time_range(UD,[UD.common.minTime,UD.common.maxTime]);
    for i=1:UD.numAxes
        UD=rescale_axes_to_fit_data(UD,i,1);
    end
    set(dialog,'UserData',UD);

