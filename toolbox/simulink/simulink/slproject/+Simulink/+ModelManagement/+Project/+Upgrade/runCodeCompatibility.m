function[checks,recommendations]=runCodeCompatibility(jFile)





    results=analyzeCodeCompatibility(char(jFile.getAbsolutePath));

    checks=i_convert2struct(results.ChecksPerformed,'Description');
    recommendations=i_convert2struct(results.Recommendations,'LineNumber');

end

function results=i_convert2struct(results,sortColumn)

    if~isempty(results)
        results=sortrows(results,sortColumn);

        for n=1:length(results.Properties.VariableNames)
            column=results.Properties.VariableNames{n};
            if isnumeric(results.(column)(1))
                results.(column)=int32(results.(column));
            else
                results.(column)=cellstr(results.(column));
            end
        end
    end

    results=table2struct(results);

end

