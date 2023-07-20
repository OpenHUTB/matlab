function result=getRecentConfigs(this)

    RecentConfigurations={};


    prefFile=fullfile(prefdir,this.prefCacheFile);
    if exist(prefFile,'file')
        mdladvprefs=load(prefFile);
        if isfield(mdladvprefs,'RecentConfigurations')
            RecentConfigurations=mdladvprefs.RecentConfigurations;
        end
    end
    result={};

    for i=1:numel(RecentConfigurations)
        [~,FileName,Ext]=fileparts(RecentConfigurations{i});
        result{end+1}=struct('Name',[FileName,Ext],'Path',RecentConfigurations{i});
    end

end