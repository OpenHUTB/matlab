





function selectElement(src)
    root=DAStudio.Root;
    arExplorerList=find(root,'-isa','AUTOSAR.Explorer');

    pos=strfind(src,'/');
    modelName=src(1:pos-1);
    nodeName=autosar.ui.utils.convertSLObjectNameToGraphicalName(src);

    arExplorer=[];
    for index=1:length(arExplorerList)
        mmgr=arExplorerList(index).MappingManager;
        activeMapping=mmgr.getActiveMappingFor('AutosarTarget');
        if strcmp(activeMapping.Name,modelName)
            arExplorer=arExplorerList(index);
            break;
        end
    end
    assert(~isempty(arExplorer),'Did not find explorer');

    if isempty(findprop(arExplorer,'NavigateInValidation'))
        navProp=schema.prop(arExplorer,'NavigateInValidation','bool');
        navProp.Visible='off';
    end
    if isempty(findprop(arExplorer,'TargetNode'))
        navProp=schema.prop(arExplorer,'TargetNode','string');
        navProp.Visible='off';
    end
    arExplorer.NavigateInValidation=true;
    arExplorer.TargetNode=nodeName;
    arExplorer.show();
    arExplorer.selectAccordionPane(autosar.ui.configuration.PackageString.mappingAccName);

end
