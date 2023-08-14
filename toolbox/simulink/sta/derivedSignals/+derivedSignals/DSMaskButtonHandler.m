function DSMaskButtonHandler(dlg,action,varargin)





    dlgSource=dlg.getDialogSource();
    signals=dlgSource.signals;

    switch action
    case 'add'

        newSigIndex=length(signals)+1;
        signals{newSigIndex,1}='';
        dlgSource.signals=signals;
        dlg.enableApplyButton(true);
    case 'remove'
        rowCount=length(signals);
        selectedSignals=dlg.getSelectedTableRows('expressionTable');
        if(~isempty(selectedSignals))
            if(rowCount==1)
                msgbox(getString(message('sl_sta_ds:staDerivedSignal:DSDefaultSignalReq')),getString(message('sl_sta_ds:staDerivedSignal:DSRemoveSignal')))
                return;
            else
                if(length(selectedSignals)==rowCount)
                    msgbox(getString(message('sl_sta_ds:staDerivedSignal:DSDefaultSignalReq')),getString(message('sl_sta_ds:staDerivedSignal:DSRemoveSignal')))
                    return;
                end

                selectedSignals=selectedSignals+1;
                signals(selectedSignals)=[];
                dlgSource.signals=signals;



                if(length(selectedSignals)>1)
                    dlg.selectTableItem('expressionTable',-1,-1);
                end

                dlg.enableApplyButton(true);
            end
        else
            msgbox(getString(message('sl_sta_ds:staDerivedSignal:DSNoRowsSelected')),getString(message('sl_sta_ds:staDerivedSignal:DSRemoveSignal')));
            return;
        end
    otherwise

    end
    dlg.refresh();
end