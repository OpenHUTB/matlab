function ft=processBasicData(resultDetailObj,ft,matchProperties)




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

    if ismember('Information',matchProperties)
        if~isempty(resultDetailObj.Information)
            ft.setCheckText(resultDetailObj.Information);
        end
    end
    if ismember('Title',matchProperties)
        if~isempty(resultDetailObj.Title)
            ft.setSubTitle(resultDetailObj.Title);
        end
    end
    if ismember('Description',matchProperties)
        if~isempty(resultDetailObj.Description)
            ft.setInformation(resultDetailObj.Description);
        end
    end
    if ismember('Status',matchProperties)
        if~isempty(resultDetailObj.Status)
            ft.setSubResultStatusText({resultDetailObj.Status});
        end
    end
    if ismember('RecAction',matchProperties)
        if~isempty(resultDetailObj.RecAction)
            ft.setRecAction({resultDetailObj.RecAction});
        end
    end
end
