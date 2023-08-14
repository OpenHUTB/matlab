function[ind,entries]=retrieveSelection(~,dlg)





    ind=dlg.getWidgetValue('signalsList')+1;
    entries=dlg.getUserData('signalsList');




    widgetName='MatchInputsString';
    if dlg.getWidgetValue(widgetName)==0
        selectedSignal=dlg.getWidgetValue('sigselector_signalsTree');
        if~isempty(selectedSignal)&&~isempty(ind)&&...
            ~isempty(entries)&&~strcmp(selectedSignal,entries(ind))
            entries(ind)=selectedSignal;
        end
    end

    if(isempty(ind))
        source=dlg.getSource();
        sig=source.getSelectedSignalString();
        for i=1:length(entries)
            for j=1:length(sig)
                if strcmp(entries{i},sig{j})
                    ind=[ind,i];
                end
            end
        end
    end
