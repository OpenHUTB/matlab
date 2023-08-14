function deletefolder(this,dirName)






    narginchk(2,2);
    this.executeCommand(strcat("rm -Rf ",dirName));
end
