function UD=chan_listbox_mgr(UD)







    chanIdx=get(UD.hgCtrls.chanListbox,'Value');
    dsIdx=UD.current.dataSetIdx;

    if chanIdx>length(UD.channels)
        return;
    end

    if isempty(UD.dataSet(dsIdx).activeDispIdx)
        axesIdx=[];
    else
        axesIdx=find(UD.dataSet(dsIdx).activeDispIdx==chanIdx);
    end

    switch(get(UD.dialog,'SelectionType'))
    case{'normal','extend','alt'}

        UD=selectSignal(UD,chanIdx,axesIdx);

    case 'open'

        if isempty(axesIdx)
            UD=signal_show(UD,chanIdx,dsIdx);
        else
            UD=signal_hide(UD,chanIdx,dsIdx,axesIdx);
        end
    end