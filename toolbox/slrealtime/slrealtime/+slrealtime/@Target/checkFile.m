function chkok=checkFile(this,localfn,remotefn,checksumdir,ssh)















    [ld,lf,~]=fileparts(localfn);
    [~,rf,~]=fileparts(remotefn);



    file=[checksumdir,'/',rf,'.cksum'];
    cmd=['/proc/boot/cat ',file];
    res=this.executeCommand(cmd,ssh);
    if res.ExitCode~=0
        chkok=-2;
        return;
    end
    tgtsum=sscanf(res.Output,'%u %u');
    if length(tgtsum)~=2
        chkok=-3;
        return;
    end

    locsumfile=fullfile(ld,lf);
    locsumfile=[locsumfile,'.cksum'];
    recreatelocsumfile=false;
    fd=fopen(locsumfile);
    if fd==-1
        recreatelocsumfile=true;
    else
        localsum=fscanf(fd,'%u %u');
        fclose(fd);
        if length(localsum)~=2
            recreatelocsumfile=true;
        end
    end




    if recreatelocsumfile





        slrealtime.qnxSetupFcn();
        cksumUtility=[];

        if ispc
            cksumUtility=fullfile(getenv('SLREALTIME_QNX_SP_ROOT'),...
            getenv('SLREALTIME_QNX_VERSION'),...
            'host','win64','x86_64','usr','bin','cksum.exe');
        end


        if exist(cksumUtility,'file')
            cksumCmd=[cksumUtility,' ',localfn,' > ',locsumfile];
            [status,~]=system(cksumCmd);
            if status


                chkok=-4;
                return;
            end

        else

            chkok=-5;
            return;
        end

        fd=fopen(locsumfile);
        if fd==-1

            chkok=-6;
            return;
        else
            localsum=fscanf(fd,'%u %u');
            fclose(fd);
            if length(localsum)~=2

                chkok=-7;
                return;
            end
        end
    end


    if all(tgtsum==localsum)
        chkok=1;
    else
        chkok=0;
    end
    return;
end
