function killProcess(this,procName)






    rootssh=this.getRootSSHObj();
    sshCmd=strcat("pidin -f a -p ",procName);
    res=this.executeCommand(sshCmd,rootssh);
    pidInfo=split(res.Output);
    pidInfo=pidInfo(~cellfun('isempty',pidInfo));
    if length(pidInfo)>1

        sshCmd=strcat("kill -9 ",pidInfo{2});
        this.executeCommand(sshCmd,rootssh);
    end
end
