



function openBlockParametersVariantSubsystemActionCB(cbinfo)

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    assert(isscalar(blocks));
    bh=blocks.handle;

    open_system(bh,'parameter');

end
