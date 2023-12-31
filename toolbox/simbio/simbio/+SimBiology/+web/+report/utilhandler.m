function out=utilhandler(action,varargin)











    out={action};

    switch(action)
    case 'appendLine'
        out=appendLine(varargin{:});
    case 'appendLineWithPad'
        out=appendLineWithPad(varargin{:});
    case 'buildPropertyValueTable'
        out=buildPropertyValueTable(varargin{:});
    case 'buildSectionHeader'
        out=buildSectionHeader(varargin{:});
    case 'buildBlackSectionHeader'
        out=buildBlackSectionHeader(varargin{:});
    case 'buildTable'
        out=buildTable(varargin{:});
    case 'buildTableWithGroupHeader'
        out=buildTableWithGroupHeader(varargin{:});
    case 'createHeaderLine'
        out=createHeaderLine(varargin{:});
    case 'areValuesDefined'
        out=areValuesDefined(varargin{:});
    case 'areValuesEqual'
        out=areValuesEqual(varargin{:});
    case 'numeric2cell'
        out=numeric2cell(varargin{:});
    case 'generateDoseHTMLFromDoseStruct'
        out=generateDoseHTMLFromDoseStruct(varargin{:});
    case 'generateFooter'
        out=generateFooter;
    case 'deleteFile'
        deleteFile(varargin{:});
    end

end

function out=areValuesDefined(list)

    out=any(cellfun(@(x)~isempty(x),list));

end

function out=areValuesEqual(list,value)

    out=all(cellfun(@(x)isequal(x,value),list));

end

function html=generateDoseHTMLFromDoseStruct(html,doses)

    repeatDoses={};
    scheduleDoses={};

    for i=1:numel(doses)
        next=doses(i).Table;
        props=next.Properties.VariableNames;
        if any(strcmp('StartTime',props))
            repeatDoses{end+1}=doses(i);%#ok<*AGROW>
        else
            scheduleDoses{end+1}=doses(i);
        end
    end

    repeatDoses=[repeatDoses{:}];
    scheduleDoses=[scheduleDoses{:}];

    if~isempty(repeatDoses)
        tableHTML=SimBiology.web.report.modelhandler('buildRepeatDoseTable',repeatDoses);
        html=appendLine(html,tableHTML);
    end

    if~isempty(scheduleDoses)
        tableHTML=SimBiology.web.report.modelhandler('buildScheduleDoseTables',scheduleDoses);
        html=appendLine(html,tableHTML);
    end

end

function out=generateFooter

    vinfo=ver('simbio');
    out=sprintf('    Report generated by SimBiology v. %s %s on %s',vinfo.Version,vinfo.Release,char(datetime('now')));

end

function out=buildSectionHeader(out,header,description)

    if isempty(out)
        out=createHeaderLine('h2',header,2);
    else
        out=appendLine(out,createHeaderLine('h2',header,1));
    end

    if~isempty(description)
        out=appendLine(out,'<p>');
        out=appendLine(out,description);
        out=appendLine(out,'</p>');
    end

end

function out=buildBlackSectionHeader(out,header,description)

    if isempty(out)
        out=createHeaderLine('h3',header,1);
    else
        out=appendLine(out,createHeaderLine('h3',header,1));
    end

    out=appendLineWithPad(out,'<div class="horizontal_border"></div>',1);

    if~isempty(description)
        out=appendLineWithPad(out,'<p>',1);
        out=appendLineWithPad(out,description,2);
        out=appendLineWithPad(out,'</p>',1);
    end

end

function out=createHeaderLine(header,text,numTabs)




    pad=blanks(numTabs*4);
    out=sprintf('%s<%s>%s</%s>',pad,header,text,header);

end

function out=buildPropertyValueTable(props,values)

    out='        <table class="propertyValueTable">';
    out=appendLineWithPad(out,'<tbody>',3);

    styles={'style="width:150px"','style="width:auto"'};
    tableHeader=buildTableHeader({'Property','Value'},styles,4);
    out=appendLine(out,tableHeader);

    for i=1:numel(props)
        next={props{i},values{i}};
        out=appendLine(out,buildTableRow(next,4));
    end

    out=appendLineWithPad(out,'</tbody>',3);
    out=appendLineWithPad(out,'</table>',2);

end

function out=buildTable(headers,data,columnStyles,headingLabel,varargin)








    out=buildTableWithGroupHeader('',headers,data,columnStyles,headingLabel,varargin{:});

end

function html=buildTableWithGroupHeader(groupHeader,headers,data,columnStyles,headingLabel,varargin)










    tableClassName='';
    if nargin>=6
        tableClassName=varargin{1};
    end

    rowStyles={};
    if nargin==7
        rowStyles=varargin{2};
    end

    if~isempty(headingLabel)
        html=sprintf('    <h2>%s</h2>',headingLabel);
    else
        html='';
    end


    if isempty(tableClassName)
        html=appendLine(html,'        <table>');
    else
        html=appendLine(html,['        <table class="',tableClassName,'">']);
    end

    for i=1:numel(groupHeader)
        tableHeader=buildGroupHeadingHTML(groupHeader(i).columnNames,groupHeader(i).spans);
        html=appendLine(html,tableHeader);
    end

    tableHeader=buildTableHeader(headers,columnStyles,3);
    html=appendLine(html,tableHeader);
    html=appendLineWithPad(html,'<tbody>',3);

    for i=1:size(data,1)
        next=data(i,:);
        rowStyle='';
        if~isempty(rowStyles)
            rowStyle=rowStyles{i};
        end

        html=appendLine(html,buildTableRow(next,4,'',rowStyle));
    end

    html=appendLineWithPad(html,'</tbody>',3);
    html=appendLineWithPad(html,'</table>',2);

end

function html=buildGroupHeadingHTML(names,spans)


    headers={};
    styles={};

    firstStyle='style="width:auto"';
    if(spans(1)~=-1)
        firstStyle=sprintf('colspan="%d" style="text-align:center;width:auto"',spans(1));
    end


    headers{end+1}=names{1};
    styles{end+1}=firstStyle;
    hasNext=length(names)>1;
    count=2;

    while hasNext
        if(spans(count)~=-1)
            textAlign='center';
            if spans(count)==1
                textAlign='left';
            end
            styles{end+1}=sprintf('colspan="%d" style="text-align:%s;width:auto"',spans(count),textAlign);
            headers{end+1}=names{count};
            count=count+spans(count);
        else
            count=count+1;
        end

        hasNext=length(names)>=count;
    end

    html=buildTableHeader(headers,styles,3);

end

function out=buildTableHeader(headerProps,columnStyles,numTabs)

    pad=blanks(numTabs*4);
    out=sprintf('%s<thead>\n%s\n%s</thead>',pad,buildTableRow(headerProps,numTabs+1,columnStyles),pad);

end

function out=buildTableRow(values,numTabs,varargin)






    columnStyles={};
    if nargin>=3
        columnStyles=varargin{1};
    end

    rowStyle='';
    if nargin==4
        rowStyle=varargin{2};
    end

    pad=blanks((numTabs)*4);
    pad2=blanks((numTabs+1)*4);

    if isempty(rowStyle)
        out=sprintf('%s<tr>',pad);
    else
        out=sprintf('%s<tr class="%s">',pad,rowStyle);
    end

    for i=1:numel(values)
        escapeValue=true;
        if isstring(values{i})&&ismissing(values{i})
            values{i}='';
        elseif isnumeric(values{i})
            if isempty(values{i})
                values{i}='[]';
            else
                values{i}=num2str(values{i});
            end
        elseif islogical(values{i})
            escapeValue=false;
            if(values{i})
                values{i}='&#10004;';
            else
                values{i}='';
            end
        elseif iscell(values{i})
            if numel(values{i})==1
                values{i}=values{i}{1};
            end
        elseif iscategorical(values{i})
            values{i}=char(values{i});
        elseif ischar(values{i})&&(numel(values{i})==1)&&(double(values{i})==0)
            values{i}='';
        end


        if escapeValue
            values{i}=strrep(values{i},'&','&amp;');
            values{i}=strrep(values{i},'<','&lt;');
            values{i}=strrep(values{i},'>','&gt;');
        end

        if~isempty(columnStyles)&&~isempty(columnStyles{i})
            out=sprintf('%s\n%s<td %s>%s</td>',out,pad2,columnStyles{i},values{i});
        elseif escapeValue
            out=sprintf('%s\n%s<td>%s</td>',out,pad2,values{i});
        else
            out=sprintf('%s\n%s<td style="text-align:center;">%s</td>',out,pad2,values{i});
        end
    end

    out=sprintf('%s\n%s</tr>',out,pad);

end

function code=appendLineWithPad(code,newLine,numTabs)

    pad=blanks(4*numTabs);
    code=SimBiology.web.codegenerationutil('appendCode',code,[pad,newLine]);

end

function code=appendLine(code,newLine)

    code=SimBiology.web.codegenerationutil('appendCode',code,newLine);

end

function deleteFile(name)

    oldWarnState=warning('off','MATLAB:DELETE:Permission');
    cleanup=onCleanup(@()warning(oldWarnState));

    if exist(name,'file')
        oldState=recycle;
        recycle('off');
        delete(name)
        recycle(oldState);
    end

end

function out=numeric2cell(data)

    out=cell(numel(data),1);
    for i=1:length(data)
        if isnan(data(i))
            out{i}='NaN';
        else
            out{i}=data(i);
        end
    end
end
