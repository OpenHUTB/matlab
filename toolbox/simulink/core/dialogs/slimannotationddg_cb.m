function slimannotationddg_cb(dlg,h,tag,value)
    CUSTOM_COLOR_ITEM=0;

    prop=tag;
    pVal=value;
    doSendUpdateEvent=true;

    switch tag
    case{'FixedWidth','FixedHeight','DropShadow','UseDisplayTextAsClickCallback'}
        if value
            pVal='on';
        else
            pVal='off';
        end
    case 'Interpreter'
        if value
            pVal='tex';
        else
            pVal='off';
        end
    case{'BackgroundColor','ForegroundColor'}
        if value==CUSTOM_COLOR_ITEM
            customColor=h.showColorDialog(strcmp(tag,'ForegroundColor'));

            if(customColor(1)>=0)
                pVal=sprintf('[%f, %f, %f]',customColor(1),customColor(2),customColor(3));
            end
        else
            pVal=colorPropName(value);
        end
    case 'HorizontalAlignment'
        pVal=alignmentPropName(value);
    case{'TopMarginEdit','RightMarginEdit','BottomMarginEdit','LeftMarginEdit'}
        prop='InternalMargins';
        leftMargin=dlg.getWidgetValue('LeftMarginEdit');
        topMargin=dlg.getWidgetValue('TopMarginEdit');
        rightMargin=dlg.getWidgetValue('RightMarginEdit');
        bottomMargin=dlg.getWidgetValue('BottomMarginEdit');
        pVal=sprintf('[%d %d %d %d]',leftMargin,topMargin,rightMargin,bottomMargin);
    case 'Font'
        newFont=chooseFont(h);
        pVal=strcat(newFont.Family,':',num2str(newFont.Size),':',newFont.Style,':',newFont.Weight);
    case 'ClickFcn'
        h.ClickFcn=value;
        doSendUpdateEvent=false;
    end

    if doSendUpdateEvent
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{prop,pVal});
    end

    if~dlg.isWidgetWithError(tag)
        dlg.clearWidgetDirtyFlag(tag)
    end
end


function name=alignmentPropName(index)
    names={'left','center','right'};
    name=names{index+1};
end

function name=colorPropName(index)
    names={'black','white','red','green','blue','yellow','magenta','cyan','gray','orange','lightBlue','darkGreen','automatic'};
    name=names{index};
end

function font=chooseFont(h)
    f=MG2.Font;
    f.Family=h.FontName;
    f.Size=h.FontSize;
    f.Weight=h.FontWeight;
    f.Style=h.FontAngle;
    font=GLUE2.Util.invokeFontPicker(f);
end