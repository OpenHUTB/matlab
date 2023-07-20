












function copyToWorkDir(this)

    userdir=this.UserDir;
    workdir=this.WorkDir;
    if strcmp(userdir,workdir)
        return;
    end

    for s=1:length(this.SubModels)

        cpfile=fullfile(userdir,[this.SubModels{s},'.slx']);
        if~exist(cpfile,'file')
            cpfile(end-2:end)='mdl';
        end
        localCopy(cpfile,workdir,this.Overwrite);
    end
    fileattrib([workdir,'*'],'+w');

    for d=1:length(this.Dependencies)


        if exist(fullfile(userdir,this.Dependencies{d}),'file')
            localCopy(fullfile(userdir,this.Dependencies{d}),workdir,this.Overwrite);
        else
            localCopy(this.Dependencies{d},workdir,this.Overwrite);
        end
    end

end

function localCopy(file,workdir,writeFlag)

    close_system(file,0);

    if strcmpi(writeFlag,'on')
        r=copyfile(file,workdir,'f');
    elseif strcmpi(writeFlag,'off')
        r=copyfile(file,workdir);
    end
    if r~=1
        DAStudio.error('RTW:cgv:CouldNotCopy',file,workdir);
    end
end

