function f=isfolder(this,dirName)




    narginchk(2,2);
    res=this.executeCommand(strcat("[ -d ",dirName," ] && echo 'EXISTS' || echo 'NOTHING' "));
    f=startsWith(res.Output,'EXISTS');
end
