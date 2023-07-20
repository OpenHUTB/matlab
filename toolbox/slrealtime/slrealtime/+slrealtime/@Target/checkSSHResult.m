function res=checkSSHResult(this,ssh)







    res=ssh.waitForResult();
    if isfield(res,'ErrorID')
        this.throwErrorAsCaller(res.ErrorID,res.ErrorMessage);
    elseif(res.ExitCode~=0)


        if isfield(res,'Output')&&~isempty(res.Output)
            errStr=res.Output;
        else
            errStr=res.ErrorOutput;
        end
        this.throwErrorAsCaller('slrealtime:target:sshError',errStr);
    end
end
