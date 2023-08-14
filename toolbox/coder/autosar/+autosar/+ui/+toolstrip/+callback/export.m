function export(cbinfo)




    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);

    if isempty(block)||...
        strcmp(get_param(block.handle,'BlockType'),'Outport')||...
        strcmp(get_param(block.handle,'BlockType'),'Inport')

        mdlH=SLStudio.Utils.getDiagramHandle(cbinfo);
        autosar.composition.studio.CreateAndLink.exportRootModel(mdlH);
    elseif autosar.composition.Utils.isCompBlockLinked(block.handle)&&...
        autosar.composition.Utils.isComponentBlock(block.handle)

        autosar.composition.studio.CreateAndLink.exportComponentBlock(block.handle);
    elseif autosar.composition.Utils.isCompositionBlock(block.handle)

        autosar.composition.studio.CreateAndLink.exportCompositionBlock(block.handle);
    else
        assert(false,'Cannot export selected block %s',getfullname(block.handle));
    end
