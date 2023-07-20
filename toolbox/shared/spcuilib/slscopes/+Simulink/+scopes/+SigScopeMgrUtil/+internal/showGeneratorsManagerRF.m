function showGeneratorsManagerRF(cbinfo,action)
    context=cbinfo.Context;
    visible=context.SSMIsVisible;
    tab=context.SSMActiveTab;
    if visible&&strcmpi(tab,'generators')
        action.selected=true;
    else
        action.selected=false;
    end
end