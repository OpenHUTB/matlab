function reboot(this)










    notify(this,'Rebooting');

    try
        rootssh=this.getRootSSHObj();
    catch ME
        notify(this,'RebootFailed');
        this.throwError('slrealtime:target:rebootError',this.TargetSettings.name,ME.message);
    end

    try

        if this.isConnected
            if(this.TargetStatus.State==slrealtime.TargetState.BUSY)
                autoImportFlag=this.StopProperties.AutoImportFileLog;
                autoImportFlagChanged=false;
                if~this.isRunning()

                    this.StopProperties.AutoImportFileLog=false;
                    autoImportFlagChanged=true;
                end
                this.stop;
                if autoImportFlagChanged
                    this.StopProperties.AutoImportFileLog=autoImportFlag;
                end
            end
        end

        platform=this.detectTargetPlatform();

        if(platform=="Linux")

            cmd='slrealtime stopdaemon; slrealtime stoplogd';
            this.executeCommand(cmd,rootssh);

            cmd=['pkill -10 statusmonitor || echo "Statusmonitor not running."'];
            this.executeCommand(cmd,rootssh);

            pause(1);


            this.executeCommand('reboot',rootssh);
        else

            cmd='slrealtime stopdaemon; slrealtime stoplogd';
            this.executeCommand(cmd,rootssh);
            cmd='slay -s 16 -Q statusmonitor || true';
            this.executeCommand(cmd,rootssh);

            pause(1);





            this.executeCommand('shutdown >/dev/null 2>/dev/null',rootssh);
        end

    catch

    end

    notify(this,'RebootIssued');


    this.disconnect;
end
