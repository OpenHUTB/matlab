

function handleEnterKeyPress(widgetId,model)

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            hmiDlgs=dlgSrc.getOpenDialogs(true);
            for j=1:length(hmiDlgs)


                if(hmiDlgs{j}.isStandAlone)
                    hmiDlgs{j}.apply;


                    hmiDlgs{j}.delete;

                end
            end
        end
    end
end
