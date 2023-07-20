function val=getsignal(this,blockPath,portIndex)





















    [blockPath,portIndex]=slrealtime.internal.SignalAccess.checkAndFormatArgs(blockPath,portIndex);

    if~this.isConnected()
        this.connect();
    end

    try


        if isempty(this.xcp)
            this.throwError('slrealtime:target:noAppLoaded');
        end

        try
            sigaccess=slrealtime.internal.SignalAccess(this.xcp,this.mldatxCodeDescFolder);
            val=sigaccess.getSignal(blockPath,portIndex);
        catch ME
            if strcmp(ME.identifier,'slrealtime:connectivity:xcpMasterError')




                appName=this.tc.ModelProperties.Application;
                this.throwError('slrealtime:target:appNotResponding',...
                appName,this.TargetSettings.name);
            else
                rethrow(ME);
            end
        end

    catch ME
        if iscell(blockPath)
            if length(blockPath)>1
                bpstr=blockPath{1};
                for i=2:length(blockPath)
                    bpstr=strcat(bpstr,'/',extractAfter(blockPath{i},'/'));
                end
            else
                bpstr=blockPath{1};
            end
        else
            bpstr=blockPath;
        end
        bpstr=[bpstr,':',num2str(portIndex)];

        this.throwErrorWithCause('slrealtime:target:getsignalError',...
        ME,bpstr,this.TargetSettings.name,ME.message);
    end
end