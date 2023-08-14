function setVariant(hThis,dlg,variantChoice)







    hBlk=pmsl_getdoublehandle(hThis.BlockHandle);

    variants=simscape.internal.variantsAndNames(hBlk);
    fcn=nesl_private('nesl_setvariant');
    fcn(hBlk,variants{variantChoice+1});
    dlg.refresh();





end
