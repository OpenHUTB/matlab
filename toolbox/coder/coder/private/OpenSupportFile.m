function[fid,fspec]=OpenSupportFile(buildInfo,filename,bldMode,encoding)






    if nargin<3
        bldMode=coder.internal.BuildMode.Normal;
    end

    buildDir=emcGetBuildDirectory(buildInfo,bldMode);
    fspec=fullfile(buildDir,filename);
    if isfile(fspec)
        [status,~,msgid]=fileattrib(fspec,'+w');
        if status==0
            error(message('Coder:buildProcess:OpenSupportFileError',fspec,message(msgid).getString));
        end
    end
    if nargin<=3

        fid=fopen(fspec,'Wt','native');
    else
        fid=fopen(fspec,'Wt','native',encoding);
    end
    if fid==-1
        error(message('Coder:buildProcess:fileOpenError',fspec));
    end
end
