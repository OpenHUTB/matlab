function[moduleNames,modulesInfo]=getModulesInProject(projName)

    moduleNames={};
    modulesInfo={};

    this.docObj=oslc.Project.get(projName);
    if~isempty(this.docObj)
        [names,modulesInfo]=getModuleNames(this.docObj);
        if~isempty(names)
            moduleNames=names';
        end
    end
end

function[moduleNames,modulesWithIds]=getModuleNames(dngProject)
    docType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_oslc');
    projInfoStr=sprintf('%s (%s)',dngProject.queryBase,dngProject.name);
    [moduleNamesLabels,~,ids]=docType.ContentsFcn(projInfoStr);


    moduleNames=cell(size(moduleNamesLabels));
    modulesWithIds=cell(size(moduleNamesLabels));
    for i=1:length(moduleNamesLabels)
        match=regexp(moduleNamesLabels{i},'^\S+\:\s+(.+)$','tokens');
        if isempty(match)
            moduleNames{i}=moduleNamesLabels{i};
        else
            moduleNames{i}=match{1}{1};
        end
        modulesWithIds{i}=[ids{i},' ',moduleNames{i}];
    end
end
