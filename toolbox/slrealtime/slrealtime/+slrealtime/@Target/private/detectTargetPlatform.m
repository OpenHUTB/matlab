function name=detectTargetPlatform(this)







    if(isempty(this.TargetSettings.address))
        this.throwError('slrealtime:target:emptyTargetIpAddr');
    end



    maxTries=10;
    for i=1:maxTries
        if ispc
            cmd=['ping -n 1 ',this.TargetSettings.address];
        else
            cmd=['ping -c 1 ',this.TargetSettings.address];
        end
        [status,result]=system(cmd);
        if~status
            break;
        end
    end
    if(i==maxTries)||~contains(result,'TTL','IgnoreCase',true)
        this.throwError('slrealtime:target:targetNotAlive',maxTries,result);
    end

    out=this.executeCommand("uname");
    name=convertCharsToStrings(out.Output);
    name=name.strip();
end