

function filterFiles=getFilterFiles(isResultSet,rs)
    if isResultSet
        filterFiles=rs.FilterFiles;
    else
        filterFiles=string.empty;
    end
end
