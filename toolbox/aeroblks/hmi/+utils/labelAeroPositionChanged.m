function labelAeroPositionChanged(dialog,obj)




    blockHandle=get(obj.blockObj,'handle');
    isCoreBlock=get_param(blockHandle,'isCoreWebBlock');
    mdl=get_param(bdroot(blockHandle),'Name');

    labelPosition=simulink.hmi.getLabelPosition(...
    dialog.getComboBoxText('labelPosition'));

    if~strcmp(isCoreBlock,'on')
        widget=utils.getWidget(mdl,obj.widgetId,obj.isLibWidget);
        if~isempty(widget)
            if widget.LabelPosition~=labelPosition
                widget.LabelPosition=labelPosition;


                set_param(mdl,'Dirty','on');


                signalDlgs=obj.getOpenDialogs(true);
                for j=1:length(signalDlgs)
                    if~isequal(dialog,signalDlgs{j})
                        utils.updateLabelPosition(signalDlgs{j},labelPosition);
                    end
                end
            end
        end
    else
        currentLabelPosition=get_param(blockHandle,'LabelPosition');
        if currentLabelPosition~=labelPosition
            set_param(blockHandle,'LabelPosition',labelPosition);


            set_param(mdl,'Dirty','on');


            signalDlgs=obj.getOpenDialogs(true);
            for j=1:length(signalDlgs)
                if~isequal(dialog,signalDlgs{j})
                    utils.updateLabelPosition(signalDlgs{j},labelPosition);
                end
            end
        end
    end
    dialog.clearWidgetDirtyFlag('labelPosition');
    dialog.enableApplyButton(false,false);
end
