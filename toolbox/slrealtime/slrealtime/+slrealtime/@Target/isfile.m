function f=isfile(this,fileName)






    narginchk(2,2);
    res=this.executeCommand(strcat("[ -f ",fileName," ] && echo 'EXISTS' || echo 'NOTHING' "));
    f=startsWith(res.Output,'EXISTS');
end
