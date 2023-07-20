function sendFile(this,src,dst,ssh)





















    narginchk(3,4);
    if nargin<4
        ssh=[];
    else
        validateattributes(ssh,{'matlabshared.network.internal.SSH'},{'scalar'});
    end
    src=convertStringsToChars(src);
    validateattributes(src,{'char'},{});
    dst=convertStringsToChars(dst);
    validateattributes(dst,{'char'},{});

    try
        if isempty(ssh)
            address=this.TargetSettings.address;
            username=this.TargetSettings.username;
            password=this.TargetSettings.userPassword;
        else
            address=ssh.Host;
            username=ssh.User;
            password=ssh.Password;
        end
        if this.UseActiveFTP
            ftpobj=ftp(address,username,password,'LocalDataConnectionMethod','active');
        else
            ftpobj=ftp(address,username,password);
        end
        clean1=onCleanup(@()ftpobj.close());

        if this.isVerbose
            disp(['Copying ',src,' to ',dst,' using ',address...
            ,'/',username,'/',password]);
        end

        [dstpath,dststem,dstext]=fileparts(dst);
        dstname=strcat(dststem,dstext);
        [srcpath,srcstem,srcext]=fileparts(src);
        srcname=strcat(srcstem,srcext);
        if~isempty(dstname)&&~strcmp(dstname,srcname)
            this.throwErrorAsCaller('slrealtime:target:sendFileError',...
            src,dst,this.TargetSettings.name,"src and dst filenames must match");
        end

        if~isempty(dstpath)
            ftpobj.cd(dstpath);
        end
        ftpobj.mput(src);

    catch ME
        this.throwErrorAsCaller('slrealtime:target:sendFileError',...
        src,dst,this.TargetSettings.name,ME.message);
    end
end
