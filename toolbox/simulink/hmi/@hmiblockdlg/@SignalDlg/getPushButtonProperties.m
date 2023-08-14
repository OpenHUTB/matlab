

function pushButtonProperties=getPushButtonProperties(widgetId,model)


    pushButtonProperties={};
    pushButtonDlgSrc='';
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            pushButtonDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(pushButtonDlgSrc)
        block=get(pushButtonDlgSrc.getBlock(),'Handle');
        pushButtonProperties{2}=get_param(block,'Icon');
        pushButtonProperties{3}=get_param(block,'CustomIcon');
    else
        pushButtonProperties{1}=[200,200,200];
        pushButtonProperties{2}='None';

        pushButtonProperties{3}='';
    end

end