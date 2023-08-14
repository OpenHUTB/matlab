function app=getLastApplication(this)





    narginchk(1,1);

    try
        app=[];
        sshCmd=strcat("ls -ltr ",this.appsDirOnTarget,' | tail -n 1');
        res=this.executeCommand(sshCmd);
        if~isempty(res.Output)
            temp=split(res.Output);
            app=char(temp(end-1));
        end

    catch ME
        throw(ME);
    end
end




