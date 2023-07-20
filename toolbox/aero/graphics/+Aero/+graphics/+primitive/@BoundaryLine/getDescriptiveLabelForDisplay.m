function label=getDescriptiveLabelForDisplay(hObj)




    if~isempty(hObj.Tag)
        label=hObj.Tag;
    else
        label=hObj.DisplayName;
    end
end