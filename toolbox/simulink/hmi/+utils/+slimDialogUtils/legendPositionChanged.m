

function legendPositionChanged(dialog,obj)


    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    widget=utils.getWidget(mdl,obj.widgetId,obj.isLibWidget);
    if~isempty(widget)
        legendPosition=dialog.getComboBoxText('legendPosition');

        widget.LegendPosition=simulink.hmi.getLegendPosition(legendPosition);


        set_param(mdl,'Dirty','on');


        signalDlgs=obj.getOpenDialogs(true);
        for j=1:length(signalDlgs)
            if~isequal(dialog,signalDlgs{j})
                utils.updateLegendPosition(signalDlgs{j},legendPosition);
            end
        end
        dialog.enableApplyButton(false,false);
    end
end
