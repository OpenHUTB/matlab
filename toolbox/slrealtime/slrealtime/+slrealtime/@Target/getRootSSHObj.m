function rootssh=getRootSSHObj(this)





    try

        if(isempty(this.TargetSettings.address))
            this.throwError('slrealtime:target:emptyTargetIpAddr');
        end

        rootssh=matlabshared.network.internal.SSH(...
        this.TargetSettings.address,...
        this.TargetSettings.sshPort,...
        'root',this.TargetSettings.rootPassword);
    catch ME
        if strfind(ME.message,'authorization returned -18')
            try

                msg=message('slrealtime:target:enterRoot','root',this.TargetSettings.name);
                rootpw=input(msg.getString,'s');
                rootssh=matlabshared.network.internal.SSH(...
                this.TargetSettings.address,...
                this.TargetSettings.sshPort,...
                'root',rootpw);

            catch err
                this.throwError('slrealtime:target:rootSSHError',this.TargetSettings.name,err.message);
            end
        else
            this.throwError('slrealtime:target:rootSSHError',this.TargetSettings.name,ME.message);
        end
    end
