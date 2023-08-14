function html=fitinhtmltable(this,headHorz,headVert,data,align,caption)






    numCols=length(headHorz);
    numRows=size(data,1);
    if~iscell(data)
        data=num2strcell(data);
    end

    table=cell(numRows,numCols);
    for n=1:numRows
        if isempty(headVert)
            table(n,:)={data{n,:}};
        else
            table(n,:)={headVert{n},data{n,:}};
        end
    end

    if length(align)==1
        for n=2:numCols
            align{n}=align{1};
        end
    end

    html=['<P> <TABLE border=1 width=400>'];

    if exist('caption','var')
        html=[html,'<caption>',caption,'</caption>'];
    end

    html=[html,'<TR>'];


    if~isempty(headVert)
        html=[html,'<TD align="right"> <B>',headHorz{1},'</B></TD>'];
    else
        html=[html,'<TD align="',align{1},'"> <B>',headHorz{1},'</B></TD>'];
    end
    for n=2:length(headHorz)
        html=[html,'<TD align="',align{n},'"> <B>',headHorz{n},'</B></TD>'];
    end
    html=[html,'</TR>'];

    for row=1:size(table,1)
        html=[html,'<TR>'];
        if~isempty(headVert)
            html=[html,'<TD align="right"><B>',table{row,1},'</B></TD>'];
        else
            html=[html,'<TD align="',align{1},'">',table{row,1},'</TD>'];
        end
        for col=2:size(table,2)
            html=[html,'<TD align="',align{col},'">',table{row,col},'</TD>'];
        end
        html=[html,'</TR>'];
    end

    html=[html,'</TABLE> </P>'];


    function cellstr=num2strcell(nummatrix)

        cellstr=cell(size(nummatrix));
        for r=1:size(nummatrix,1)
            for c=1:size(nummatrix,2)
                cellstr(r,c)={num2str(nummatrix(r,c))};
            end
        end

