function propSetSystemObject(this,dlg,propValue,property,propertyInfo)



    this.DialogManager.propSetSystemObject(dlg,propValue,property,propertyInfo);









    widgetTag=propertyInfo.Tag;
    if property.IsSystemObject
        if any(strcmp(propValue,property.ClassStringSet.Set))


            setToExpression=strcmp(propValue,property.ClassStringSet.CustomExpressionLabel);
            DAStudio.delayedCallback(@focusAndResizeOnRefresh,widgetTag,dlg.getUserData(widgetTag),setToExpression);
        else

            DAStudio.delayedCallback(@resizeOnRefresh,widgetTag,dlg.getUserData(widgetTag));
        end
    elseif property.IsLogical||property.IsStringSet||property.IsEnumeration


        DAStudio.delayedCallback(@resizeOnRefresh,widgetTag,dlg.getUserData(widgetTag));
    end

    function resizeOnRefresh(widgetTag,dialogID)
        dlg=getOpenDialog(widgetTag,dialogID);
        if isempty(dlg)
            return;
        end

        dlg.resetSize;

        function focusAndResizeOnRefresh(comboboxTag,dialogID,setToExpression)
            dlg=getOpenDialog(comboboxTag,dialogID);
            if isempty(dlg)
                return;
            end


            if setToExpression
                dlg.setWidgetValue(comboboxTag,'');
            end

            dlg.setFocus(comboboxTag);
            dlg.resetSize;

            function dlg=getOpenDialog(comboboxTag,dialogID)

                openDlgs=DAStudio.ToolRoot.getOpenDialogs;
                for dlgInd=1:numel(openDlgs)
                    dlg=openDlgs(dlgInd);
                    if strcmp(dlg.getUserData(comboboxTag),dialogID)
                        return;
                    end
                end
                dlg='';
