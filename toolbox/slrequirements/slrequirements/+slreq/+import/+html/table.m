function html=table(headerData,tableData,tablespec)


    if~isempty(headerData)&&~all(strcmp(headerData,''))

        if size(headerData,2)~=size(tableData,2)
            error('htmlTable(): mismatched header/data size');
        end
        if nargin<3
            tablespec='border=1 cellpadding="5"';
        end
        html=['<table ',tablespec,'>',newline];
        html=[html,'<tr>'];
        for i=1:size(headerData,2)
            html=[html,'<th>',headerData{i},'</th>'];%#ok<AGROW>
        end
        html=[html,'</tr>',newline];
    else

        if nargin<3
            tablespec='cellpadding="2"';
        end
        html=['<table ',tablespec,'>',newline];
    end


    for i=1:size(tableData,1)
        html=[html,'<tr>'];%#ok<AGROW>
        for j=1:size(tableData,2)
            if contains(tableData{i,j},'<a name=')
                html=[html,'<td valign="top">',tableData{i,j},'</td>'];%#ok<AGROW>
            else
                html=[html,'<td>',tableData{i,j},'</td>'];%#ok<AGROW>
            end
        end
        html=[html,'</tr>',newline];%#ok<AGROW>
    end
    html=[html,'</table>',newline];
end
