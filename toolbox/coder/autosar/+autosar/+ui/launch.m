





function explorer=launch(model)


    mapping=autosar.api.Utils.modelMapping(model);
    mapping.sync();
    arRoot=autosar.api.Utils.m3iModel(model);
    modelName=get_param(model,'Name');
    explorerTitle=autosar.ui.utils.getExplorerTitle(modelName);

    m3iComp=autosar.api.Utils.m3iMappedComponent(model);

    autosar.validation.AutosarUtils.checkAdaptiveModelSetup(modelName);

    explorer=autosar.ui.utils.initTargetModelExplorer([],arRoot,m3iComp.qualifiedName,model,explorerTitle);




    if~autosar.api.Utils.isMappedToComposition(model)
        explorer.TraversedRoot.installListener(model);
    end


    tip=AUTOSAR.Tip;
    tip.Explorer=explorer;
    explorer.installViewManager(tip,false);




    expPos=explorer.Position;
    mdlPos=get_param(model,'Location');
    newPos1=mdlPos(1)+100;
    newPos2=mdlPos(2)+100;
    explorer.Position=[newPos1,newPos2,expPos(3),expPos(4)];

    explorer.LoadCompleteHierarchy=1;

    explorer.show();
    explorer.showAccordionPane(autosar.ui.configuration.PackageString.targetAccName);

    explorer.DAObjectMappingRoot=explorer.getRoot();
end
