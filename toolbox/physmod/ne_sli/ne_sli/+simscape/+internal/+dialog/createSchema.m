function pmdlg=createSchema(componentSchema)






















    fcn=nesl_private('nesl_create_pmdialogschema');
    blkHandle=simscape.internal.dialog.currentBlockHandle();
    if isempty(blkHandle)||~ishandle(blkHandle)
        pm_error('physmod:ne_sli:internal:InvalidCurrentBlockHandle');
    end
    pmdlg=fcn(componentSchema,blkHandle);

end
