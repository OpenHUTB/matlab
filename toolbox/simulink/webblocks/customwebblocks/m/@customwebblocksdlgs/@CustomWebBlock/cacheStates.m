

function cacheStates(widgetId,model,statesJson)
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        if strcmpi(dlgs(i).dialogMode,'slim')


            continue;
        end
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            dlgSrc.CachedStates=statesJson;
            dlgs(i).enableApplyButton(true,true);
            break;
        end
    end
end