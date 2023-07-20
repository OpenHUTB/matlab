function str=pm_unsprintf(str)












    narginchk(1,1);




    lastStr='';
    while~strcmp(lastStr,str)
        lastStr=str;
        str=regexprep(str,'([^\\])\\([^\\]|$)','$1\\\\$2');
    end

end
