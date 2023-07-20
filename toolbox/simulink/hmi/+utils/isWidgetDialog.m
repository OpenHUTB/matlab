
function bIsWidgetDialog=isWidgetDialog(dlgSrc,widgetId,model)

    bIsWidgetDialog=false;
    if isprop(dlgSrc,'widgetId')&&strcmp(dlgSrc.widgetId,widgetId)
        if isa(dlgSrc,'hmiblockdlg.SDIScope')
            dlgModel=dlgSrc.parent;
        else
            dlgModel=get_param(bdroot(dlgSrc.blockObj.Handle),'Name');
        end
        if(dlgModel==model)
            bIsWidgetDialog=true;
        end
    end

