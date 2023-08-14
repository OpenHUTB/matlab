function result=convertLegendStringToUseTerminalNames(str,terminals,referenceTerminal)%#ok<INUSL> (argument is used inside a character vector
    result=str;
    result=regexprep(result,'(?<=\{(\d*))(\d)(?=(\d*)\})','${terminals{str2double($1)}}');
    result=regexprep(result,'(?<=V_\{(\w*))\}',[referenceTerminal,'\}']);
end