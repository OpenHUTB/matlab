function deletefile(this,fileName)






    narginchk(2,2);
    this.executeCommand(strcat("rm -f ",fileName));
end
