function outputHtml=table2html(inputTable,varargin)




    parseObject=inputParser;
    parseObject.addParameter('LinkToSections',false);
    parseObject.addParameter('AddHtmlTags',true);
    parseObject.addParameter('EmptyTableHtml',...
    sprintf('<p>%s</p>',getString(message('physmod:ee:billofmaterials:NoParameters'))));
    parseObject.parse(varargin{:});

    if isempty(inputTable)

        outputHtml=parseObject.Results.EmptyTableHtml;
    else


        if isprop(inputTable.Properties.CustomProperties,'DisplayVariableNames')
            variableNames=inputTable.Properties.CustomProperties.DisplayVariableNames;
        else

            variableNames=inputTable.Properties.VariableNames;
        end


        variableNames=makeHtmlSafe(variableNames);

        if isprop(inputTable.Properties.CustomProperties,'DisplayRowNames')
            rowNames=inputTable.Properties.CustomProperties.DisplayRowNames;
        else

            rowNames=inputTable.Properties.RowNames;
        end


        rowNames=makeHtmlSafe(rowNames);
        if isprop(inputTable.Properties.CustomProperties,'RowIsEnum')
            rowIsEnum=inputTable.Properties.CustomProperties.RowIsEnum;
        else
            rowIsEnum=false(height(inputTable),1);
        end

        tableHeaderHtml=sprintf('<th>%s</th>',variableNames{:});

        tableHeaderHtml=sprintf('<tr><th></th>%s</tr>',tableHeaderHtml);
        tableContents=[rowNames,makeHtmlSafe(table2cell(inputTable))];

        rowContentsHtml=cell(size(tableContents,1),1);
        for rowIdx=1:size(tableContents,1)
            tableColumnFormat=cellfun(@class,tableContents(rowIdx,:),'UniformOutput',false);
            for formatIdx=1:length(tableColumnFormat)
                switch(tableColumnFormat{formatIdx})
                case 'char'
                    if rem(formatIdx,2)==0&&rowIsEnum(rowIdx)


                        tableColumnFormat{formatIdx}='<pre>%s</pre>';
                    else
                        tableColumnFormat{formatIdx}='%s';
                    end
                case 'double'
                    if isscalar(tableContents{rowIdx,formatIdx})

                        tableColumnFormat{formatIdx}='%g';
                    else

                        [nRows,nCols]=size(tableContents{rowIdx,formatIdx});
                        formatSpecifier=join(repmat({'%g'},1,nCols),',');
                        formatSpecifier=join(repmat(formatSpecifier,nRows,1),';<br>');
                        tableColumnFormat{formatIdx}=formatSpecifier{1};
                    end
                case{'logical','uint32'}
                    tableColumnFormat{formatIdx}='%i';
                otherwise
                    tableColumnFormat{formatIdx}=sprintf('%s: %%i',getString(message('physmod:ee:billofmaterials:UnknownDatatype')));
                end
            end
            tableElementHtml=sprintf('<td>%s</td>',tableColumnFormat{:});
            tableRowHtml=sprintf('<tr>%s</tr>',tableElementHtml);
            if parseObject.Results.LinkToSections
                tableContents{rowIdx,1}=sprintf('<a href="#%s"><b>%s</b></a>',strrep(tableContents{rowIdx},' ','%20'),tableContents{rowIdx});
            else
                tableContents{rowIdx,1}=sprintf('<b>%s</b>',tableContents{rowIdx});
            end

            rowContentsHtml{rowIdx}=sprintf(tableRowHtml,tableContents{rowIdx,:});
        end
        tableContents=[{tableHeaderHtml};rowContentsHtml];
        tableContentsHtml=sprintf('%s',tableContents{:});
        outputHtml=sprintf('<table>%s</table><br><br>',tableContentsHtml);
    end

    if parseObject.Results.AddHtmlTags
        outputHtml=sprintf('<html>%s</html>',outputHtml);
    end

    outputHtml=strrep(outputHtml,newline,'<br>');

end

