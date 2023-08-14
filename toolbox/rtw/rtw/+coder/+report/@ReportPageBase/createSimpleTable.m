function table=createSimpleTable(contents,option,col_width_vec,align_vec)

    if isempty(contents)
        table='<table><tr><td></td></tr></table>';
        return
    end
    numCol=length(contents);
    table='<table width="100%" cellpadding="2" ';
    if option.HasBorder
        table=[table,' border=1 '];
    end
    if isfield(option,'BeginWithWhiteBG')&&option.BeginWithWhiteBG
        table=[table,' style="background-color: #ffffff" '];
    else
        table=[table,' style="background-color: #eeeeff" '];
    end
    nl=sprintf('\n');
    table=[table,'>',nl];
    table=[table,'<tr>'];
    tds=cell(1,numCol);
    for j=1:numCol
        tds{j}=sprintf('<td align="%s" width="%.2f%%">%s</td>\n',align_vec{j},col_width_vec(j),contents{j}{1});
    end
    table=[table,tds{:},'</tr></table>'];
end
