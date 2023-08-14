

function[success,errormsg]=preApplyCB(obj,dlg)


    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        success=true;
        errormsg='';
        return;
    end

    labelPosition=simulink.hmi.getLabelPosition(...
    dlg.getComboBoxText('labelPosition'));

    format=simulink.hmi.getDisplayBlockFormat(...
    dlg.getComboBoxText('format'));

    alignment=simulink.hmi.getDisplayBlockAlignment(...
    dlg.getComboBoxText('alignment'));

    opacity=dlg.getWidgetValue('opacity');
    formatString=dlg.getWidgetValue('formatString');
    fitToView=simulink.hmi.getDisplayBlockLayout(...
    dlg.getComboBoxText('fitToView'));
    showGridValue=dlg.getWidgetValue('showGrid');

    backgroundcolor=obj.BackgroundColor;
    foregroundcolor=obj.ForegroundColor;
    gridColor=obj.GridColor;

    set_param(blockHandle,'LabelPosition',labelPosition);
    set_param(blockHandle,'Format',format);
    set_param(blockHandle,'Alignment',alignment);
    set_param(blockHandle,'Opacity',opacity);
    set_param(blockHandle,'Layout',fitToView);
    if showGridValue==1
        showGridValue='on';
    else
        showGridValue='off';
    end
    set_param(blockHandle,'ShowGrid',showGridValue);

    if strcmp(dlg.getComboBoxText('format'),DAStudio.message('SimulinkHMI:dashboardblocks:CUSTOM'))
        set_param(blockHandle,'FormatString',formatString);
    end
    set_param(blockHandle,'BackgroundColor',backgroundcolor);
    set_param(blockHandle,'ForegroundColor',foregroundcolor);
    set_param(blockHandle,'GridColor',jsondecode(gridColor));
    bindSignal(obj);

    success=true;
    errormsg='';


    set_param(mdl,'Dirty','on');



    scChannel='/hmi_displayblock_colors_controller_/';
    signalDlgs=obj.getOpenDialogs(true);
    for j=1:length(signalDlgs)
        signalDlgs{j}.enableApplyButton(false,false);

        if~isequal(dlg,signalDlgs{j})
            utils.updateLabelPosition(signalDlgs{j},labelPosition);
            utils.updateFormat(signalDlgs{j},format);
            utils.updateAlignment(signalDlgs{j},alignment);
            utils.updateOpacity(signalDlgs{j},opacity);
            utils.updateFitToView(signalDlgs{j},fitToView);
            utils.updateShowGrid(signalDlgs{j},showGridValue);
            message.publish([scChannel,'updateColors'],...
            {false,obj.widgetId,mdl,backgroundcolor,foregroundcolor,gridColor});
        end
    end
end


