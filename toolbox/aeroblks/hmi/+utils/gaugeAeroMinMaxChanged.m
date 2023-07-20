function gaugeAeroMinMaxChanged(dialog,obj,varargin)




    if isempty(varargin)
        MinMaxTickIntervalPropertiesToUpdate={};
        if strcmp(obj.get_param('webBlockType'),'climbindicator')
            minimumValue='0';
        else
            minimumValue=dialog.getWidgetValue('minimumValue');
        end
        maximumValue=dialog.getWidgetValue('maximumValue');
        [success,errormsg,~]=utils.validateMinMaxTickIntervalFields(minimumValue,...
        maximumValue,'auto',dialog,true);
        if~success
            errordlg(errormsg);
            return;
        end

        MinMaxTickIntervalPropertiesToUpdate{1}=minimumValue;
        MinMaxTickIntervalPropertiesToUpdate{2}=maximumValue;

        minimumValue=eval(minimumValue);
        maximumValue=eval(maximumValue);



        blockHandle=get(obj.blockObj,'handle');
        mdl=get_param(bdroot(blockHandle),'Name');

        widget=utils.getWidget(mdl,obj.widgetId,obj.isLibWidget);

        if~isempty(widget)

            if~(minimumValue<=widget.Value&&widget.Value<=maximumValue)
                if(minimumValue<=0&&0<=maximumValue)
                    widget.Value=0;
                else
                    widget.Value=minimumValue;
                end
            end

            widget.ScaleLimits=[minimumValue,maximumValue];

            set_param(mdl,'Dirty','on');


            signalDlgs=obj.getOpenDialogs(true);
            for j=1:length(signalDlgs)
                if~isequal(dialog,signalDlgs{j})
                    utils.updateAeroMinMaxIntervalFields(signalDlgs{j},MinMaxTickIntervalPropertiesToUpdate);
                end
            end
            dialog.enableApplyButton(false,false);
        end
    else

        MinMaxTickIntervalPropertiesToUpdate={};
        blockHandle=get(obj.blockObj,'handle');
        mdl=get_param(bdroot(blockHandle),'Name');

        if utils.isAeroHMILibrary(mdl)
            return;
        end

        isClimbIndicator=strcmp(get_param(blockHandle,'BlockType'),'ClimbIndicatorBlock');

        if isClimbIndicator
            minimumValue='0';
        else
            minimumValue=strtrim(dialog.getWidgetValue('minimumValue'));
        end
        maximumValue=strtrim(dialog.getWidgetValue('maximumValue'));
        success=utils.validateMinMaxTickIntervalFields(minimumValue,...
        maximumValue,'auto',dialog,true);
        if~success
            return;
        end

        MinMaxTickIntervalPropertiesToUpdate{1}=minimumValue;
        MinMaxTickIntervalPropertiesToUpdate{2}=maximumValue;

        minimumValue=eval(minimumValue);
        maximumValue=eval(maximumValue);



        if isClimbIndicator
            set_param(blockHandle,'ScaleMax',num2str(maximumValue));
        else
            set_param(blockHandle,'ScaleMin',num2str(minimumValue),...
            'ScaleMax',num2str(maximumValue));
        end


        set_param(mdl,'Dirty','on');


        signalDlgs=obj.getOpenDialogs(true);
        for j=1:length(signalDlgs)
            if~isequal(dialog,signalDlgs{j})

                if isClimbIndicator
                    signalDlgs{j}.setWidgetValue('maximumValue',MinMaxTickIntervalPropertiesToUpdate{2});
                    signalDlgs{j}.enableApplyButton(false,false);
                else
                    utils.updateAeroMinMaxIntervalFields(signalDlgs{j},MinMaxTickIntervalPropertiesToUpdate);
                end

            end
        end
        dialog.clearWidgetWithError('minimumValue');
        dialog.clearWidgetWithError('maximumValue');

        dialog.clearWidgetDirtyFlag('minimumValue');
        dialog.clearWidgetDirtyFlag('maximumValue');

        dialog.enableApplyButton(false,false);

    end
end
