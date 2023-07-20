function str=escapeSpecialCharInJS(str)

    str=strrep(str,char(10),' ');
    str=strrep(str,'\','\\');
    str=strrep(str,'"','\"');
end
