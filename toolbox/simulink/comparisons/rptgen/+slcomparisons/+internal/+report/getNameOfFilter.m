function filterName=getNameOfFilter(filterID)





    switch filterID
    case "sldiff.filter.lines"
        filterName=message("simulink_comparisons:rptgen:LinesFilter").getString;
    case "sldiff.filter.nonfunctional"
        filterName=message("simulink_comparisons:rptgen:NonfunctionalChangesFilter").getString;
    otherwise

        filterName=filterID;
    end

end