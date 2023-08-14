




function editPackage(m3iObject,parentDlg,itemTag)




    pkgValue=parentDlg.getWidgetValue(itemTag);
    modelM3I=m3iObject.modelM3I;
    assert(modelM3I.RootPackage.size==1);
    maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(modelM3I);
    errmsg=autosar.ui.utils.isValidARIdentifier(pkgValue,'absPath',maxShortNameLength);
    isvalid=isempty(errmsg);
    if~isvalid
        errordlg(errmsg,autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
        return;
    end
    m3iPkg=autosar.mm.Model.getOrAddARPackage(modelM3I,pkgValue);
    assert(m3iPkg.isvalid());

    if~strcmp(itemTag,'CompPkgTextTag')


        m3iObject=m3iPkg;
    end



    parentDlg.apply;



    pkgTree=autosar.ui.metamodel.PackageTree(m3iObject,parentDlg,itemTag);
    DAStudio.Dialog(pkgTree);

end
