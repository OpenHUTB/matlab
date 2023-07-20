function res=invokeDefaultSSH(this,method,varargin)






















    success=false;
    attempts=2;
    while attempts>0
        attempts=attempts-1;
        try




            if~isempty(this.sshDoNotUseDirectly)







                addressMatch=strcmp(this.sshDoNotUseDirectly.Host,this.TargetSettings.address);
                sshPortMatch=this.sshDoNotUseDirectly.Port==this.TargetSettings.sshPort;
                usernameMatch=strcmp(this.sshDoNotUseDirectly.User,this.TargetSettings.username);
                passwordMatch=strcmp(this.sshDoNotUseDirectly.Password,this.TargetSettings.userPassword);
                if~(addressMatch&&sshPortMatch&&usernameMatch&&passwordMatch)
                    this.sshDoNotUseDirectly=[];
                end
            end
            if isempty(this.sshDoNotUseDirectly)
                try
                    this.sshDoNotUseDirectly=matlabshared.network.internal.SSH(...
                    this.TargetSettings.address,...
                    this.TargetSettings.sshPort,...
                    this.TargetSettings.username,...
                    this.TargetSettings.userPassword);
                catch
                    this.sshDoNotUseDirectly=[];
                end
                if isempty(this.sshDoNotUseDirectly)
                    this.disconnect();
                    this.throwErrorAsCaller('slrealtime:target:sshCommunicationError',...
                    this.TargetSettings.name);
                end
            end





            this.sshDoNotUseDirectly.(method)(varargin{:});
            res=this.checkSSHResult(this.sshDoNotUseDirectly);

        catch ME



            errmsg=[];
            strs=split(ME.message,':');
            if~isempty(strs)
                errmsg=strtrim(strs{end});
            end




            if isempty(errmsg)||strcmp(errmsg,'Unable to send channel-open request')...
                ||strcmp(errmsg,'Unexpected error')




                this.sshDoNotUseDirectly=[];
                continue;
            end




            if contains(errmsg,'command already in progress')




                try
                    locSSH=matlabshared.network.internal.SSH(...
                    this.TargetSettings.address,...
                    this.TargetSettings.sshPort,...
                    this.TargetSettings.username,...
                    this.TargetSettings.userPassword);
                catch
                    locSSH=[];
                end
                if isempty(locSSH)
                    this.throwErrorAsCaller('slrealtime:target:sshCommunicationError',...
                    this.TargetSettings.name);
                else
                    locSSH.(method)(varargin{:});
                    res=this.checkSSHResult(locSSH);
                    success=true;
                end
                break;
            end




            rethrow(ME);
        end
        success=true;
        break;
    end
    if~success
        this.disconnect();
        this.throwErrorAsCaller('slrealtime:target:sshCommunicationError',...
        this.TargetSettings.name);
    end
end
