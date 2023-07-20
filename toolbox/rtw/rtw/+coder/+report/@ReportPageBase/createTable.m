function table=createTable(contents,option,col_width_vec,align_vec)
    assert(length(col_width_vec)==length(contents));
    table=Advisor.Table(1,1);

    if isempty(contents)
        return
    end
    numCol=length(contents);
    numRow=length(contents{1});
    if numRow==0
        return
    end
    table=Advisor.Table(numRow,numCol);
    if option.HasBorder
        table.setBorder(1);
    else
        table.setBorder(0);
    end
    if isfield(option,'BeginWithWhiteBG')&&option.BeginWithWhiteBG
        table.setStyle('AltRowBgColorBeginWithWhite');
    else
        table.setStyle('AltRowBgColor');
    end
    table.setAttribute('width','100%');
    for i=1:numCol
        table.setColWidth(i,col_width_vec(i));
    end
    for j=1:numCol
        for i=1:numRow
            if isempty(contents{j}{i})
                aText=Advisor.Text('');
            else
                aText=Advisor.Text(contents{j}{i});
            end
            aText.ContentsContainHTML=true;
            table.setEntry(i,j,aText);

            if j>1
                table.setEntryAlign(i,j,align_vec{j});
            end
        end
    end
    if option.HasHeaderRow
        for j=1:numCol
            element=Advisor.Element;
            element.setContent(table.getEntry(1,j).emitHTML);
            element.setTag('b');
            table.setEntry(1,j,element);
        end
    end
    table.setAttribute('cellpadding','2');
end
