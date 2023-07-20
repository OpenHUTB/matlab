function[UD,modified]=signal_hide(UD,chanIdx,dsIdx,axesIdx)







    UD=hide_channel(UD,chanIdx);
    UD=remove_axes(UD,axesIdx);
    UD.dataSet(dsIdx).activeDispIdx(axesIdx)=[];

    UD=update_undo(UD,'hide','channel',chanIdx,dsIdx);

    if~isempty(UD.dataSet(dsIdx).activeDispIdx)

        if(axesIdx-1)~=0
            chanIdx=UD.dataSet(dsIdx).activeDispIdx(axesIdx-1);
        else
            chanIdx=UD.dataSet(dsIdx).activeDispIdx(axesIdx);
        end

    end

    UD=selectSignal(UD,chanIdx,UD.dataSet(dsIdx).activeDispIdx);
    UD=update_show_menu(UD);

    modified=1;
    UD=set_dirty_flag(UD);
