function enumMode=getFilterModeEnum(stringMode)
    switch stringMode
    case 'Exclude'
        enumMode=advisor.filter.FilterMode.Exclude;
    case 'Justify'
        enumMode=advisor.filter.FilterMode.Justify;
    otherwise
        enumMode=advisor.filter.FilterMode.Exclude;

    end
end