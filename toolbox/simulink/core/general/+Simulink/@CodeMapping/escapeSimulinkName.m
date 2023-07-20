function res=escapeSimulinkName(pathStr)






    pathStr=strrep(pathStr,newline,' ');
    res=strrep(pathStr,'/','//');
end
