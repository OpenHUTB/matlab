function slimboxddg_cb(dlg,h,tag,value)

    prop=tag;
    pVal=value;
    doSendUpdateEvent=true;

    switch prop
    case 'DropShadow'
        if value
            pVal='on';
        else
            pVal='off';
        end
    case 'AreaColor'
        prop='ForegroundColor';
        colorMap=getColorMap();
        colorValues=colorMap(:,2);
        colorValue=colorValues{value+1};
        if strcmp(colorValue,'[-1 -1 -1]')
            colorValue=h.showColorDialog(true);
            if(colorValue(1)>=0)
                pVal=sprintf('[%f, %f, %f]',colorValue(1),colorValue(2),colorValue(3));
            end
        else
            pVal=colorValue;
        end
    case 'Font'
        newFont=chooseFont(h);
        pVal=strcat(newFont.Family,':',num2str(newFont.Size),':',newFont.Style,':',newFont.Weight);
    case 'Description'
        h.Description=value;
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

function colorMap=getColorMap()
    colorMap={'Brown','[0.972549, 0.952941, 0.929412]';...
    'Cyan','[0.901961, 0.960784, 1.000000]';...
    'Gray','[0.952941, 0.952941, 0.952941]';...
    'Green','[0.956863, 0.980392, 0.921569]';...
    'Magenta','[0.968627, 0.925490, 0.976471]';...
    'Red','[0.992157, 0.937255, 0.913725]';...
    'Violet','[0.901961, 0.901961, 1.000000]';...
    'Yellow','[0.996078, 0.968627, 0.909804]';...
    'Custom','[-1 -1 -1]';};
end

function font=chooseFont(h)
    f=MG2.Font;
    f.Family=h.FontName;
    f.Size=h.FontSize;
    f.Weight=h.FontWeight;
    f.Style=h.FontAngle;
    font=GLUE2.Util.invokeFontPicker(f);
end