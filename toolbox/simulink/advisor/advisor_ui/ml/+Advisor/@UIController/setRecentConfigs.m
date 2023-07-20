function setRecentConfigs(this,configFullFile)

    RecentConfigurations={};
    bAppend=false;

    prefFile=fullfile(prefdir,this.prefCacheFile);
    if exist(prefFile,'file')
        mdladvprefs=load(prefFile);
        if isfield(mdladvprefs,'RecentConfigurations')
            RecentConfigurations=mdladvprefs.RecentConfigurations;
        end
        bAppend=true;
    end
    RecentConfigurations=unique([configFullFile;RecentConfigurations]);
    if numel(RecentConfigurations)>3
        RecentConfigurations=RecentConfigurations(1:3);
    end
    if bAppend
        save(prefFile,'RecentConfigurations','-append');
    else
        save(prefFile,'RecentConfigurations');
    end

end