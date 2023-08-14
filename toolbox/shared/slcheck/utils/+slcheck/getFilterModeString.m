function stringMode=getFilterModeString(enumMode)
    switch enumMode
    case advisor.filter.FilterMode.Exclude
        stringMode='Exclude';
    case advisor.filter.FilterMode.Justify
        stringMode='Justify';
    otherwise
        stringMode='';
    end
end