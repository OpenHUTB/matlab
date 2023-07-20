function test=validateRequiredDirectories(cfg,prompt)



    test=false;
    if(2>nargin)
        prompt=false;
    end


    if(any(cellfun(@any,regexp(fieldnames(cfg),'PrivateData')))&&...
        isfield(cfg.PrivateData,'RequiredToolDirectories')&&...
        ~isempty(cfg.PrivateData.RequiredToolDirectories)&&...
        iscell(cfg.PrivateData.RequiredToolDirectories))
        for index=1:length(cfg.PrivateData.RequiredToolDirectories)
            location=cfg.PrivateData.(cfg.PrivateData.RequiredToolDirectories{index})();
            if(isempty(location.Path)||~location.exists())
                cfg.OperationalReason=DAStudio.message(['ERRORHANDLER:xmakefile:xmk_warning_Functions_'...
                ,cfg.PrivateData.RequiredToolDirectories{index},'_unidentified']);
                if(prompt)
                    userSelection=uigetdir('',DAStudio.message(['ERRORHANDLER:xmakefile:xmk_ui_title_'...
                    ,cfg.PrivateData.RequiredToolDirectories{index}]));
                    if(0==userSelection)
                        return;
                    end
                    installPath=linkfoundation.util.Location(userSelection);
                    if(isempty(installPath.Path)||~installPath.exists())
                        return;
                    end









                    if isprop(cfg,'CustomValidator')&&...
                        ~isempty(cfg.CustomValidator)&&...
                        (exist(which(cfg.CustomValidator),'file')~=0)
                        validatorHandle=str2func(cfg.CustomValidator);
                        [cool,msg]=validatorHandle(installPath.Path);
                        if~cool
                            MSLDiagnostic(msg).reportAsWarning;
                            return;
                        end
                    end


                    linkfoundation.xmakefile.XMakefilePreferences.setPreference(cfg.PrivateData.RequiredToolDirectories{index},installPath.Path);
                else
                    return;
                end
            end
        end
    end

    cfg.OperationalReason='';
    test=true;

end
