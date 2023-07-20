







function retVal=getargstr(prmStr)

    tmpVal=regexprep(prmStr,...
    '(VAR|CONST|P2VAR|P2CONST|CONSTP2VAR|CONSTP2CONST)\(.*?\)','');
    tmpVal=regexprep(tmpVal,'(\[\d+\]\s*|\*)','');
    tmpVal=regexprep(tmpVal,'\s+,','');
    retVal=regexprep(tmpVal,'\w+\s+','');
