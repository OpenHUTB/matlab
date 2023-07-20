function justifyBlockForMISRA(block,type,kind,status,classification)
    dlg=pslink.BlockAnnotation(block);
    dlg.PSAnnotationType=type;
    dlg.PSAnnotationKind=kind;
    dlg.PSOnlyOneCheck=1;
    dlg.PSStatus=status;
    dlg.PSClassification=classification;
    dlg.PSComment='';
    DAStudio.Dialog(dlg);
end

