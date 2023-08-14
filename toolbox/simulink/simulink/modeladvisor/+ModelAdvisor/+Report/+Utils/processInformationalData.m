function ft=processInformationalData(resultDetailObj)




    if resultDetailObj.Type==ModelAdvisor.ResultDetailType.String&&~isempty(resultDetailObj.Data)

        ft=resultDetailObj.Data;
    else
        ft=ModelAdvisor.FormatTemplate('TableTemplate');

        if~resultDetailObj.IsInformer
            switch(resultDetailObj.violationType)
            case ModelAdvisor.CheckStatus.Warning
                ft.setSubResultStatus('warn');
            case ModelAdvisor.CheckStatus.Failed
                ft.setSubResultStatus('fail');
            case ModelAdvisor.CheckStatus.Passed
                ft.setSubResultStatus('pass');
            otherwise
                ft.setSubResultStatus('none');
            end
        end
        if~isempty(resultDetailObj.Description)
            ft.setCheckText(resultDetailObj.Description);
        end
        if~isempty(resultDetailObj.Title)
            ft.setSubTitle(resultDetailObj.Title);
        end
        if~isempty(resultDetailObj.Information)
            ft.setInformation(resultDetailObj.Information);
        end
        if~isempty(resultDetailObj.Status)
            ft.setSubResultStatusText({resultDetailObj.Status});
        end
        if~isempty(resultDetailObj.RecAction)
            ft.setRecAction({resultDetailObj.RecAction});
        end
    end
end
