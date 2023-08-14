function argName=convertPortNameToArgName(portName)







    argName=regexprep(strtrim(portName),'[\W]+','_');
    argName=sprintf('%s',argName);
