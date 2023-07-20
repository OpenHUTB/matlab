function[UD,modified]=signal_show(UD,chanIdx,dsIdx)







    if is_space_for_new_axes(UD.current.axesExtent,UD.geomConst,UD.numAxes)
        newAxesIdx=sum(UD.dataSet(dsIdx).activeDispIdx>chanIdx)+1;
        UD=new_axes(UD,newAxesIdx,[]);
        UD=new_plot_channel(UD,chanIdx,newAxesIdx);
        UD.current.channel=chanIdx;
        mouse_handler('ForceMode',[],UD,3);
        UD=update_channel_select(UD);
        UD=update_show_menu(UD);
        UD=update_undo(UD,'show','channel',chanIdx,dsIdx);
        UD=set_dirty_flag(UD);
        modified=1;
    else
        msgTxt=getString(message('sigbldr_ui:signal_show:InsufficientSpace'));
        warndlg(msgTxt,getString(message('sigbldr_ui:signal_show:WarnTitle')));
        modified=0;
    end
