function res=executeCommand(this,command,ssh)

















    narginchk(2,3);
    if nargin<3
        ssh=[];
    elseif~isempty(ssh)
        validateattributes(ssh,{'matlabshared.network.internal.SSH'},{'scalar'});
    end
    command=convertStringsToChars(command);
    validateattributes(command,{'char'},{});

    try
        if this.isVerbose
            disp(['Executing ''',command,''' on target computer']);
        end

        if isempty(ssh)
            res=this.invokeDefaultSSH('execute',command);
        else
            ssh.execute(command);
            res=this.checkSSHResult(ssh);
        end
    catch ME
        this.throwErrorAsCaller('slrealtime:target:executeCommandError',...
        this.TargetSettings.name,ME.message,command);
    end
end

