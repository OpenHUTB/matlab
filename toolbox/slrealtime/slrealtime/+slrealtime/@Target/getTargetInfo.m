function[status,info,rootssh]=getTargetInfo(this)




    info=[];
    status=0;
    rootssh=this.getRootSSHObj;


    cmd="/usr/target/bin/tgsupportinfo.sh >/root/info.txt";
    res=this.executeCommand(cmd,rootssh);
    if res.ExitCode~=0
        status=1;
        return;
    end


    if strcmpi(computer('arch'),'win64')
        tmpFile='c:\TEMP\info.txt';
        printCmd='type';
    elseif strcmpi(computer('arch'),'glnxa64')
        tmpFile='/tmp/info.txt';
        printCmd='cat';
    end


    this.receiveFile('/root/info.txt',tmpFile)

    cmd="rm /root/info.txt";
    res=this.executeCommand(cmd,rootssh);
    if res.ExitCode~=0
        status=1;
        return;
    end

    [stat,out]=system([printCmd,' ',tmpFile]);
    if stat~=0
        status=1;
        return;
    end
    info=out;
end
