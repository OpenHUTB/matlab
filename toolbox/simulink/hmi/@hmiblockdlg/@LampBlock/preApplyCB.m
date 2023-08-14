

function[success,errormsg]=preApplyCB(obj,dlg)


    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        success=true;
        errormsg='';
        return;
    end

    currentlabelPosition=get_param(blockHandle,'LabelPosition');

    labelPosition=simulink.hmi.getLabelPosition(...
    dlg.getComboBoxText('labelPosition'));

    labelPositionChanged=false;
    if isequal(currentlabelPosition,'Top')||~isequal(labelPosition,0)
        labelPositionChanged=true;
    elseif isequal(currentlabelPosition,'Bottom')||~isequal(labelPosition,1)
        labelPositionChanged=true;
    elseif isequal(currentlabelPosition,'Hide')||~isequal(labelPosition,2)
        labelPositionChanged=true;
    end

    [values,colors,success,errormsg]=utils.validateLampStates(obj);

    if success
        if labelPositionChanged
            if obj.ApplyColorChange
                set_param(blockHandle,'DefaultColor',obj.DefaultColor);
                obj.ApplyColorChange=false;
            end
        else
            set_param(blockHandle,'DefaultColor',obj.DefaultColor);
        end

        if~obj.ApplyCustom
            set_param(blockHandle,'LabelPosition',labelPosition,...
            'States',{values,colors},...
            'Icon',obj.Icon,...
            'CustomIcon',obj.CustomIcon);
        else
            if~strlength(obj.CustomIcon)
                set_param(blockHandle,'LabelPosition',labelPosition,...
                'States',{values,colors},...
                'Icon','Default',...
                'CustomIcon',obj.CustomIcon)
            else
                set_param(blockHandle,'LabelPosition',labelPosition,...
                'States',{values,colors},...
                'Icon','Custom',...
                'CustomIcon',obj.CustomIcon);
            end

        end

        bindSignal(obj);


        set_param(mdl,'Dirty','on');

        lampDlgs=obj.getOpenDialogs(true);
        for j=1:length(lampDlgs)
            if isequal(lampDlgs{j},dlg)

                lampDlgSrc=lampDlgs{j}.getSource;
                if obj.ApplyCustom
                    if~strlength(obj.CustomIcon)
                        lampDlgSrc.icon='Default';
                    else
                        lampDlgSrc.icon='Custom';
                    end
                end
                lampDlgs{j}.enableApplyButton(false,false);
            else
                scChannel='/hmi_lamp_controller_/';
                lampColorsData{1}=values;
                lampColorsData{2}=colors;
                lampColorsData{3}=obj.DefaultColor;
                message.publish([scChannel,'updateProperties'],...
                {false,obj.widgetId,mdl,lampColorsData});
            end
        end

    end

    opacity=dlg.getWidgetValue('opacity');
    set_param(blockHandle,'Opacity',opacity);
end
