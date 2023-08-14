function prompt=getPromptForWidget(hDialog,widgetTag)










    prompt=hDialog.getWidgetPrompt(widgetTag);
    if isempty(prompt)
        userData=hDialog.getUserData(widgetTag);
        if isfield(userData,'detailPrompt')
            prompt=userData.detailPrompt;
        end
        if isempty(prompt)
            try
                widgetSrc=hDialog.getWidgetSource(widgetTag);
                prompt=widgetSrc.IntrinsicDialogParameters.(widgetTag).Prompt;
            catch %#ok<CTCH>
                prompt='';
            end
            if isempty(prompt)
                try
                    prompt=hDialog.getWidgetValue([widgetTag,'_Prompt_Tag']);
                catch
                    prompt='';
                end
            end
        end
    end
