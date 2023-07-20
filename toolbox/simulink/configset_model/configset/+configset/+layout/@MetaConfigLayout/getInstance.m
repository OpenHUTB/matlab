function obj=getInstance(varargin)






mlock
    persistent configsetLayout

    matFile=configset.layout.MetaConfigLayout.BaseMatFile;
    xmlFile=fullfile(configset.layout.MetaConfigLayout.DataPath,configset.layout.MetaConfigLayout.XmlFileName);
    customCCPath=configset.layout.MetaConfigLayout.CustomCCPath;

    if isempty(varargin)
        dm=configset.internal.getConfigSetStaticData;
        if isempty(configsetLayout)&&dm.isValid
            if loc_needReGen(matFile)
                configset.layout.MetaConfigLayout.buildAll(matFile,xmlFile,customCCPath);
            else
                tmp=load(matFile);
                configsetLayout=tmp.configsetLayout;


                components=dm.registerComponent;
                for i=1:length(components)
                    path=dm.registerComponent(components{i});
                    configsetLayout.loadComponent(components{i},path);
                end
            end
        end
        obj=configsetLayout;
    else
        if strcmp(varargin{1},'new')
            obj=configset.layout.MetaConfigLayout.buildAll(matFile,xmlFile,customCCPath);
        end
    end

    function out=loc_needReGen(saveFile)
        matfile=dir(saveFile);
        if isempty(matfile)
            out=true;
        else
            out=false;
        end

