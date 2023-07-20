function out=createDefaultComponentModel(compBlock,mdlName)




    compBlockCreator=autosar.composition.studio.CompBlockCreateModel(compBlock);
    compBlockCreator.convert(mdlName);

    out=DAStudio.message('autosarstandard:validation:Composition_ComponentBlockCreatedDefaultModel',mdlName);


