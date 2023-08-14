function showViewersManagerRF(cbinfo,action)
    context=cbinfo.Context;
    visible=context.SSMIsVisible;
    tab=context.SSMActiveTab;
    if visible&&strcmpi(tab,'viewers')
        action.selected=true;
    else
        action.selected=false;
    end
end