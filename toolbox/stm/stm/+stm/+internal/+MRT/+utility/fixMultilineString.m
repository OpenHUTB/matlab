function harnessString=fixMultilineString(harnessString)




    harnessString=strrep(harnessString,'%','%%');
    harnessString=strrep(harnessString,newline,'\n');
end
