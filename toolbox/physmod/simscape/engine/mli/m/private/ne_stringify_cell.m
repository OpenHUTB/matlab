function str=ne_stringify_cell(strCell)
    quoter=@(x)sprintf('''%s'',',x);
    quotedStrCell=cellfun(quoter,strCell,'UniformOutput',false);
    quotedStrComma=cell2mat(quotedStrCell);
    quotedStr=quotedStrComma(1:end-1);
    str=['{',quotedStr,'}'];
