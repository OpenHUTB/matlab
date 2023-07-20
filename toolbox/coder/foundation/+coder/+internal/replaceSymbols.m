function fileContent=replaceSymbols(fileContent,oldSymbols,newSymbols)









    for ii=1:numel(oldSymbols)
        pat=['\<',oldSymbols{ii},'(?![\."])\>'];
        fileContent=regexprep(fileContent,pat,newSymbols{ii},'freespacing');
    end

