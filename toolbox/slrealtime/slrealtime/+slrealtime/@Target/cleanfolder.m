function cleanfolder(this,path)






    narginchk(2,2);
    sshCmd=strcat("cd ",path," && rm -rf * && cd -");
    this.executeCommand(sshCmd);
end
