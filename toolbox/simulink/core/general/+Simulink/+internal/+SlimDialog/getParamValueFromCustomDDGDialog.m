function value=getParamValueFromCustomDDGDialog(source,param)










    blkH=source.getBlock.Handle;
    value=get_param(blkH,param);





    dlgs=DAStudio.ToolRoot.getOpenDialogs(source);
    for i=1:length(dlgs)
        dlg=dlgs(i);
        if~isempty(intersect(dlg.getWidgetsWithError(),{param}))


            value=locGetWidgetValueAsString(dlg,param);
            break;
        end
    end

end

function value=locGetWidgetValueAsString(dlg,tag)




    value=dlg.getWidgetValue(tag);
    if ischar(value)
        return;
    end


    text=dlg.getComboBoxText(tag);
    if~isempty(text)
        value=text;
        return;
    end


    if value==1
        value='on';
    else
        assert(value==0);
        value='off';
    end

end
