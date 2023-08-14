






function this=setupModel(this)



    oldpath=addpath(this.UserDir);



    if(~isempty(this.UserAddedConfigSet)||~isempty(this.ConfigSetName))
        applyUserConfigset(this);
    end

    for s=1:length(this.PostLoadFilesList)
        sf=this.PostLoadFilesList{s};
        [~,~,ext]=fileparts(sf);
        if any(strcmp(ext,{'.m','.mlx'}))
            disp(DAStudio.message('RTW:cgv:PostLoadFile',sf));

            origFolder=pwd;
            [folder,mfile]=fileparts(sf);
            if~isempty(folder)
                cd(folder);
            end
            evalin('base',mfile);
            if~isempty(folder)
                cd(origFolder);
            end
        end
        if strcmp(ext,'.mat')
            disp(DAStudio.message('RTW:cgv:PostLoadFile',sf));
            sf=sf(1:end-4);
            evalin('base',['load(''',sf,''');']);
        end
    end

    path(oldpath);

end

