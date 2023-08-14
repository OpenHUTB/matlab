function schema=ColorMenu(fncname,cbinfo)



    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        fnc(cbinfo);
    end
end

function schema=CanvasColorMenu(cbinfo)%#ok<*DEFNU>
    schema=CanvasColorMenuSF(cbinfo);

    schema.obsoleteTags={'Simulink:ScreenColorMenu'};

    schema.state=loc_getCanvasColorMenuState(cbinfo);

    if~strcmpi(schema.state,'Hidden')
        checkedColor=loc_getCheckedColor(cbinfo,'Canvas');
    else
        checkedColor='';
    end

    schema.childrenFcns={{@loc_ColorSchema,{'Canvas','Black',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','White',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','Red',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','Green',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','Blue',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','Cyan',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','Magenta',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','Yellow',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','Gray',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','LightBlue',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','Orange',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','DarkGreen',checkedColor}},...
    {@loc_ColorSchema,{'Canvas','Custom',checkedColor}}
    };
end

function schema=CanvasColorMenuSF(~)
    schema=sl_container_schema;
    schema.tag='Simulink:CanvasColorMenu';
    schema.label=DAStudio.message('Simulink:studio:CanvasColorMenu');
    schema.state='Disabled';


    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function state=loc_getCanvasColorMenuState(cbinfo)
    state='Disabled';
    if~SLStudio.Utils.isLockedSystem(cbinfo)
        if cbinfo.isContextMenu&&cbinfo.selection.size>0
            state='Hidden';
        else
            state='Enabled';
        end
    end
end

function result=loc_isCustomColor(color)
    result=~isempty(color)&&color(1)=='[';
end

function schema=loc_ColorSchema(cbinfo)
    type=cbinfo.userdata{1};
    color=cbinfo.userdata{2};
    checked=cbinfo.userdata{3};

    schema=sl_toggle_schema;
    schema.label=DAStudio.message(['Simulink:studio:Color',color]);

    if strcmp(type,'Canvas')
        schema.userdata=color;
        schema.callback=@SetCanvasColorCB;
        schema.tag=['Simulink:Canvas_',color];
        schema.obsoleteTags={['Simulink:ScreenColor',color]};
        schema.state=loc_getCanvasColorMenuState(cbinfo);
    else
        schema.tag=['Simulink:',type,'_',color];
        schema.userdata.color=color;
        if strcmp(type,'Foreground')
            schema.obsoleteTags={['Simulink:ForegroundColor',color]};
            schema.callback=@SetForegroundColorCB;
            schema.state=loc_getForegroundColorMenuState(cbinfo);
        elseif strcmp(type,'Background')
            schema.obsoleteTags={['Simulink:BackgroundColor',color]};
            schema.callback=@SetBackgroundColorCB;
            schema.state=loc_getBackgroundColorMenuState(cbinfo);
        end
    end

    if strcmpi(color,checked)||(strcmpi(color,'Custom')&&loc_isCustomColor(checked))
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

end

function SetForegroundColorForObjects(handles,connectors,color)
    colorStr=sprintf('[%f %f %f]',color(1),color(2),color(3));

    SetColorFromParamHandles(handles,'ForegroundColor',colorStr);

    if~isempty(connectors)
        for index=1:length(connectors)
            connectors(index).color=color;
        end
    end
end

function SetColorFromParamHandles(handles,param,color)
    for index=1:length(handles)
        set_param(handles(index),param,color);
    end
end

function SetCanvasColorCB(cbinfo)
    color=cbinfo.userdata;
    if strcmpi(color,'Custom')

        oldColor=get_param(cbinfo.uiObject.handle,'ScreenColor');
        hexColor=SimulinkInternal.Util.getColorFromString(oldColor);
        c=GLUE2.Util.invokeColorPicker(hexColor);
        if isempty(c)
            return
        end
        color=sprintf('[%f %f %f]',c(1),c(2),c(3));
    end
    editor=cbinfo.studio.App.getActiveEditor;
    editor.createMCommand('Simulink:studio:SetCanvasColorCommand',DAStudio.message('Simulink:studio:SetCanvasColorCommand'),@SetColorFromParamHandles,{cbinfo.uiObject.handle,'ScreenColor',color});
end

function color=loc_getCheckedColor(cbinfo,type)
    color='';

    if strcmpi(type,'Canvas')
        color=get_param(cbinfo.uiObject.handle,'ScreenColor');
    else

        parts=SLStudio.Utils.partitionSelectionHandles(cbinfo);


        handles=[parts.blocks,parts.notes];
        connectors=[];

        if strcmpi(type,'Foreground')
            paramName='ForegroundColor';
        else
            paramName='BackgroundColor';
        end

        for index=1:length(handles)
            if isempty(color)
                color=get_param(handles(index),paramName);
            else
                itemColor=get_param(handles(index),paramName);
                if~strcmpi(itemColor,color)
                    color='';
                    return;
                end
            end
        end


        if strcmpi(type,'Foreground')
            connectors=SLStudio.Utils.partitionSelectionOf(cbinfo,'connectors');
            for index1=1:length(connectors)
                if isempty(color)
                    color=SimulinkInternal.Util.getStringFromColor(connectors(index1).color,true);
                else
                    itemColor=SimulinkInternal.Util.getStringFromColor(connectors(index1).color,true);
                    if~strcmpi(itemColor,color)
                        color='';
                        return;
                    end
                end
            end
        end
    end
end

function schema=ForegroundColorMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:ForegroundColorMenu';
    schema.label=DAStudio.message('Simulink:studio:ForegroundColorMenu');

    schema.obsoleteTags={'Simulink:ForegroundColorMenu'};

    schema.state=loc_getForegroundColorMenuState(cbinfo);
    if~strcmpi(schema.state,'Hidden')
        checkedColor=loc_getCheckedColor(cbinfo,'Foreground');
    else
        checkedColor='';
    end
    schema.childrenFcns={{@loc_ColorSchema,{'Foreground','Black',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','White',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','Red',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','Green',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','Blue',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','Cyan',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','Magenta',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','Yellow',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','Gray',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','LightBlue',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','Orange',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','DarkGreen',checkedColor}},...
    {@loc_ColorSchema,{'Foreground','Custom',checkedColor}}
    };
end

function state=loc_getForegroundColorMenuState(cbinfo)
    hasBlocks=SLStudio.Utils.selectionHasBlocks(cbinfo);
    hasNotes=~isempty(SLStudio.Utils.getSelectedAnnotationHandles(cbinfo));
    hasConnectors=SLStudio.Utils.selectionHasConnectors(cbinfo);
    if cbinfo.isContextMenu&&~hasNotes&&~hasBlocks&&~hasConnectors
        state='Hidden';
    else
        state='Disabled';
    end
    if~SLStudio.Utils.isLockedSystem(cbinfo)
        if hasBlocks||hasNotes||hasConnectors
            state='Enabled';
        end
    end
end

function SetForegroundColorCB(cbinfo)
    if SLStudio.Utils.showInToolStrip(cbinfo)
        color=SLStudio.Utils.colorHex2Float(cbinfo.EventData);
    else
        color=cbinfo.userdata.color;
    end



    parts=SLStudio.Utils.partitionSelectionHandles(cbinfo);
    connectors=SLStudio.Utils.partitionSelectionOf(cbinfo,'connectors');


    handles=[parts.blocks,parts.notes];
    blockHandles=[];
    customBlockHandles=[];
    if strcmpi(color,'Custom')
        oldColor=loc_getCommonBlockForegroundColor(handles);
        hexColor=SimulinkInternal.Util.getColorFromString(oldColor);
        c=GLUE2.Util.invokeColorPicker(hexColor);
        if isempty(c)
            return
        end
    else
        c=SimulinkInternal.Util.getColorFromString(color);
    end

    for index=1:length(handles)
        if loc_isCustomWebBlock(handles(index))
            customBlockHandles=[customBlockHandles,handles(index)];
        else
            blockHandles=[blockHandles,handles(index)];
        end
    end


    if~isempty(customBlockHandles)
        color=sprintf('[%f %f %f]',c(1),c(2),c(3));
        color=jsondecode(strrep(color,' ',','));
        for index=1:length(customBlockHandles)
            DAStudio.CustomWebBlocks.notifyWebFrontEnd(customBlockHandles(index),'ForegroundColor',jsonencode(color),'undoable');
        end
    end

    if~isempty(blockHandles)||~isempty(connectors)
        editor=cbinfo.studio.App.getActiveEditor;
        editor.createMCommand('Simulink:studio:SetForegroundColorCommand',DAStudio.message('Simulink:studio:SetForegroundColorCommand'),@SetForegroundColorForObjects,{blockHandles,connectors,c});
    end
end

function schema=BackgroundColorMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:BackgroundColorMenu';
    schema.label=DAStudio.message('Simulink:studio:BackgroundColorMenu');

    schema.obsoleteTags={'Simulink:BackgroundColorMenu'};

    if~strcmpi(schema.state,'Hidden')
        checkedColor=loc_getCheckedColor(cbinfo,'Background');
    else
        checkedColor='';
    end

    schema.state=loc_getBackgroundColorMenuState(cbinfo);
    schema.childrenFcns={{@loc_ColorSchema,{'Background','Black',checkedColor}},...
    {@loc_ColorSchema,{'Background','White',checkedColor}},...
    {@loc_ColorSchema,{'Background','Red',checkedColor}},...
    {@loc_ColorSchema,{'Background','Green',checkedColor}},...
    {@loc_ColorSchema,{'Background','Blue',checkedColor}},...
    {@loc_ColorSchema,{'Background','Cyan',checkedColor}},...
    {@loc_ColorSchema,{'Background','Magenta',checkedColor}},...
    {@loc_ColorSchema,{'Background','Yellow',checkedColor}},...
    {@loc_ColorSchema,{'Background','Gray',checkedColor}},...
    {@loc_ColorSchema,{'Background','LightBlue',checkedColor}},...
    {@loc_ColorSchema,{'Background','Orange',checkedColor}},...
    {@loc_ColorSchema,{'Background','DarkGreen',checkedColor}},...
    {@loc_ColorSchema,{'Background','Custom',checkedColor}},...
    {@loc_ColorSchema,{'Background','Automatic',checkedColor}},...
    };
end

function state=loc_getBackgroundColorMenuState(cbinfo)
    if cbinfo.isContextMenu
        state='Hidden';
    else
        state='Disabled';
    end
    if~SLStudio.Utils.isLockedSystem(cbinfo)
        if SLStudio.Utils.selectionHasBlocks(cbinfo)||~isempty(SLStudio.Utils.getSelectedNoteAnnotationHandles(cbinfo))
            state='Enabled';
        end
    end
end

function SetBackgroundColorCB(cbinfo)
    if SLStudio.Utils.showInToolStrip(cbinfo)
        color=SLStudio.Utils.colorHex2Float(cbinfo.EventData);
    else
        color=cbinfo.userdata.color;
    end


    parts=SLStudio.Utils.partitionSelectionHandles(cbinfo);
    noteAnnotations=SLStudio.Utils.getSelectedNoteAnnotationHandles(cbinfo);


    handles=[reshape(parts.blocks,1,[]),reshape(noteAnnotations,1,[])];
    blockHandles=[];
    customBlockHandles=[];

    if strcmpi(color,'Custom')

        oldColor=loc_getCommonBlockBackgroundColor(handles);
        hexColor=SimulinkInternal.Util.getColorFromString(oldColor);
        c=GLUE2.Util.invokeColorPicker(hexColor);
        if isempty(c)
            return
        end
        color=sprintf('[%f %f %f]',c(1),c(2),c(3));
    end

    for index=1:length(handles)
        if loc_isCustomWebBlock(handles(index))
            customBlockHandles=[customBlockHandles,handles(index)];
        else
            blockHandles=[blockHandles,handles(index)];
        end
    end




    if~isempty(customBlockHandles)
        customColor=struct;
        customColor.color=jsondecode(strrep(color,' ',','));
        customColor.show=true;
        customColor.setByUser=true;
        for index=1:length(customBlockHandles)
            DAStudio.CustomWebBlocks.notifyWebFrontEnd(customBlockHandles(index),'CustomBackgroundColor',jsonencode(customColor),'undoable');
        end
        if isempty(blockHandles)
            return;
        end
    end
    editor=cbinfo.studio.App.getActiveEditor;
    if~isempty(blockHandles)
        editor.createMCommand('Simulink:studio:SetBackgroundColorCommand',...
        DAStudio.message('Simulink:studio:SetBackgroundColorCommand'),...
        @SetColorFromParamHandles,{blockHandles,'BackgroundColor',color});
    elseif SLStudio.Utils.showInToolStrip(cbinfo)
        editor.createMCommand('Simulink:studio:SetCanvasColorCommand',...
        DAStudio.message('Simulink:studio:SetCanvasColorCommand'),...
        @SetColorFromParamHandles,{cbinfo.uiObject.handle,'ScreenColor',color});
    end
end

function result=loc_isCustomWebBlock(handle)
    result=false;
    obj=get_param(handle,'Object');
    if isa(obj,'Simulink.CustomWebBlock')||...
        isa(obj,'Simulink.CustomTuningWebBlock')||...
        isa(obj,'Simulink.CustomStandaloneWebBlock')
        result=true;
    end
end

function commonColor=loc_getCommonBlockForegroundColor(handles)
    commonColor=loc_getCommonBlockColor(handles,'Foreground');
end

function commonColor=loc_getCommonBlockBackgroundColor(handles)
    commonColor=loc_getCommonBlockColor(handles,'Background');
end

function commonColor=loc_getCommonBlockColor(handles,type)

    gray='Gray';
    commonColor=gray;
    for i=1:numel(handles)
        handle=handles(i);
        if loc_isCustomWebBlock(handle)&&strcmp(type,'Background')




            customColor=jsondecode(get_param(handle,'CustomBackgroundColor'));
            color=customColor.color;
        else
            color=get_param(handle,[type,'Color']);
        end
        if i==1
            commonColor=color;
        elseif~strcmp(commonColor,color)
            commonColor=gray;
            break;
        end
    end
end

function[success,noop]=setCustomColor(handles,param,color)
    success=true;
    noop=false;
    try
        for index=1:length(handles)
            set_param(handles(index),param,color);
        end
    catch
        success=false;
    end

end


