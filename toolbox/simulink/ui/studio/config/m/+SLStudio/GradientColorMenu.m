function schema=GradientColorMenu(~,cbinfo)



    schema=sl_container_schema;
    schema.tag='Simulink:AreaGradientColorMenu';
    schema.label=DAStudio.message('Simulink:studio:AreaColorMenu');

    schema.state=loc_getGradientColorMenuState(cbinfo);
    if~strcmpi(schema.state,'Hidden')
        checkedColor=loc_getCheckedColor(cbinfo);
    else
        checkedColor='';
    end



    schema.childrenFcns={{@loc_ColorSchema,{'Brown',[0.972549,0.952941,0.929412],checkedColor}},...
    {@loc_ColorSchema,{'Cyan',[0.901961,0.960784,1],checkedColor}},...
    {@loc_ColorSchema,{'Gray',[0.952941,0.952941,0.952941],checkedColor}},...
    {@loc_ColorSchema,{'Green',[0.956863,0.980392,0.921569],checkedColor}},...
    {@loc_ColorSchema,{'Magenta',[0.968627,0.92549,0.976471],checkedColor}},...
    {@loc_ColorSchema,{'Red',[0.992157,0.937255,0.913725],checkedColor}},...
    {@loc_ColorSchema,{'Violet',[0.901961,0.901961,1],checkedColor}},...
    {@loc_ColorSchema,{'Yellow',[0.996078,0.968627,0.909804],checkedColor}},...
    {@loc_ColorSchema,{'Custom',[-1,-1,-1],checkedColor}}
    };
end

function state=loc_getGradientColorMenuState(cbinfo)
    if cbinfo.isContextMenu
        state='Hidden';
    else
        state='Disabled';
    end
    parts=SLStudio.Utils.partitionSelection(cbinfo);
    if~SLStudio.Utils.isLockedSystem(cbinfo)
        if~isempty(parts.notes)
            state='Enabled';
        end
    end
end

function schema=loc_ColorSchema(cbinfo)
    colorName=cbinfo.userdata{1};
    colorRGB=cbinfo.userdata{2};
    checkedColor=cbinfo.userdata{3};

    schema=sl_toggle_schema;
    schema.label=DAStudio.message(['Simulink:studio:Color',colorName]);

    schema.tag=['Simulink:AreaColor_',colorName];
    schema.userdata.colorName=colorName;
    schema.userdata.colorRGB=colorRGB;

    schema.callback=@loc_SetColorCB;
    schema.state=loc_getGradientColorMenuState(cbinfo);


    if checkedColor==colorRGB
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
end

function checkedColor=loc_getCheckedColor(cbinfo)
    parts=SLStudio.Utils.partitionSelectionHandles(cbinfo);
    handles=[parts.notes];
    if~isempty(handles)&&length(handles)==1
        checkedColorStr=get_param(handles,'ForegroundColor');
        checkedColor=SimulinkInternal.Util.getColorFromString(checkedColorStr);
    else
        checkedColor=[-1,-1,-1];
    end
end

function loc_SetColorCB(cbinfo)
    colorName=cbinfo.userdata.colorName;
    colorRGB=cbinfo.userdata.colorRGB;


    parts=SLStudio.Utils.partitionSelectionHandles(cbinfo);


    handles=[parts.notes];
    if~isempty(handles)
        if strcmpi(colorName,'Custom')

            if length(handles)==1
                oldColor=get_param(handles,'ForegroundColor');
                hexColor=SimulinkInternal.Util.getColorFromString(oldColor);
                colorRGB=GLUE2.Util.invokeColorPicker(hexColor);
            else
                colorRGB=GLUE2.Util.invokeColorPicker;
            end
            if isempty(colorRGB)
                return
            end
        end

        colorRGBStr=sprintf('[%f %f %f]',colorRGB(1),colorRGB(2),colorRGB(3));
        editor=cbinfo.studio.App.getActiveEditor;
        editor.createMCommand(...
        'Simulink:studio:SetAreaColorCommand',...
        DAStudio.message('Simulink:studio:SetAreaColorCommand'),...
        @SetColorFromParamHandles,...
        {handles,'ForegroundColor',colorRGBStr}...
        );
    end
end

function SetColorFromParamHandles(handles,param,color)
    for index=1:length(handles)
        set_param(handles(index),param,color);
    end
end


