function[table,rowNumber]=getHTMLClassStructTable(obj,members,lvl,id,rowNumber,hasMdlRefVars,colWidthsInPercent,colAlignment)
    table=Advisor.Table(length(members),1);
    table.setAttribute('style','display: none; border-style: none');
    table.setBorder(0);
    table.setAttribute('width','100%');
    table.setAttribute('cellpadding','0');
    table.setAttribute('cellspacing','0');
    table.setAttribute('name',id);
    table.setAttribute('id',id);
    option.HasBorder=false;
    option.HasHeaderRow=false;
    indent='';
    lvl=lvl+1;
    indent(1:lvl*6)=' ';
    indent=strrep(indent,' ','&#160;');
    for i=1:length(members)
        if isempty(members(i).Members)
            prefix='&#160;&#160;';
            button=['&#160;<span style="font-family:monospace">',prefix,'</span>&#160;'];
        else
            option.UseSymbol=true;
            option.ShowByDefault=true;
            option.tooltip='Click to shrink or expand tree';
            id=[id,'_sub',num2str(rowNumber)];%#ok
            button=rtw.report.Report.getRTWTableShrinkButton(id,option);
        end
        col1={['<span style="white-space:nowrap">',indent,button,' ',members(i).Name,'</span>']};
        col2={int2str(members(i).Size)};
        if members(i).IsBitField
            col2{1}=[col2{1},'(',obj.msgs.bit,')'];
        end






        if mod(rowNumber,2)
            option.BeginWithWhiteBG=false;
        else
            option.BeginWithWhiteBG=true;
        end
        rowNumber=rowNumber+1;
        if hasMdlRefVars
            col5={' '};
            contents={col1,col2,col5};
        else
            contents={col1,col2};
        end
        subTable=obj.createSimpleTable(contents,option,colWidthsInPercent,colAlignment);
        if isempty(members(i).Members)
            table.setEntry(i,1,subTable);
        else
            [struct_table,rowNumber]=obj.getHTMLClassStructTable(members(i).Members,lvl,id,rowNumber,hasMdlRefVars,colWidthsInPercent,colAlignment);
            tmpTable=Advisor.Table(2,1);
            tmpTable.setBorder(0);
            tmpTable.setAttribute('width','100%');
            tmpTable.setAttribute('cellpadding','0');
            tmpTable.setAttribute('cellspacing','0');
            tmpTable.setEntry(1,1,subTable);
            tmpTable.setEntry(2,1,struct_table);
            table.setEntry(i,1,tmpTable);
        end
    end
end
