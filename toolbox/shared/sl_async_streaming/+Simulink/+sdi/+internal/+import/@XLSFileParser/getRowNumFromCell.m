function rowNum=getRowNumFromCell(~,cellStr)
    rowNum=str2double(regexprep(cellStr,{'\D*([\d\.]+\d)[^\d]*','[^\d\.]*'},{'$1 ',' '}));
end