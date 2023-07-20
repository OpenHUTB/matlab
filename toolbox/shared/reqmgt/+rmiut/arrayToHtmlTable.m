function tableString=arrayToHtmlTable(varargin)




    tableData=varargin{1};
    numCols=size(tableData,2);

    if nargin>1&&isstruct(varargin{2})
        opts=varargin{2};
        if~isfield(opts,'header')
            opts.header=true;
        end
        if~isfield(opts,'padding')
            opts.padding=5;
        end
        if~isfield(opts,'border')
            opts.border=1;
        end
    else
        opts.header=true;
        opts.padding=5;
        opts.border=1;
    end
    tableOpen=sprintf('<table border=%d cellpadding=%d>',opts.border,opts.padding);

    tableClose='</table>';
    if isfield(opts,'header')&&opts.header
        for i=1:numCols
            tableData{1,i}=['<b>',tableData{1,i},'</b>'];
        end
    end

    table=strcat('<tr><td>',tableData(:,1));
    for i=2:numCols
        table=strcat(table,'</td><td>');
        table=strcat(table,tableData(:,i));
    end
    table=strcat(table,['</td></tr>',char(10)]);
    tableString=strrep(strcat(table{:}),'</tr><tr>',['</tr>',char(10),'<tr>']);
    tableString=[tableOpen,char(10),tableString,char(10),tableClose];
end


