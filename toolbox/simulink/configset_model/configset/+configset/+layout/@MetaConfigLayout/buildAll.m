function configsetLayout=buildAll(matFile,xmlFile,customCCPath)




    configsetLayout=configset.layout.MetaConfigLayout(xmlFile);
    if exist(matFile,'file')
        delete(matFile);
    end
    save(matFile,'configsetLayout');


    customComponentClasses=loc_getClassNames(customCCPath);
    layoutMap=containers.Map;


    for i=1:length(customComponentClasses)
        componentClass=customComponentClasses{i};
        configset.layout.ComponentConfigLayout.buildComponentXml(configsetLayout,componentClass,'','');
        layoutMap(componentClass)=true;
    end


    customCCDataPath=fullfile(matlabroot,configset.internal.data.MetaConfigSet.DataPath,'CustomCC');
    customComponentClasses=loc_getClassNames(customCCDataPath);
    for i=1:length(customComponentClasses)
        componentClass=customComponentClasses{i};
        if~layoutMap.isKey(componentClass)
            configsetLayout.MetaCS.loadComponent(componentClass,'');
        end
    end

    configsetLayout.checkMissingWidgets;

    function out=loc_getClassNames(path)

        xmlFiles=dir(fullfile(path,'*.xml'));
        for i=1:length(xmlFiles)
            cmp=xmlFiles(i).name;
            [~,name,~]=fileparts(cmp);
            if endsWith(name,'.Layout')
                name=name(1:end-7);
            end
            out{i}=name;%#ok<AGROW>
        end

