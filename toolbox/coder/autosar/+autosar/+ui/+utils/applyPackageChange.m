




function applyPackageChange(m3iObject,dialog,packageTag)
    pkgValue=dialog.getWidgetValue(packageTag);


    modelM3I=m3iObject.modelM3I;
    assert(modelM3I.RootPackage.size==1);

    maxShortNameLength=autosar.ui.utils.getAutosarMaxShortNameLength(modelM3I);
    errmsg=autosar.ui.utils.isValidARIdentifier(pkgValue,'absPath',maxShortNameLength);
    isvalid=isempty(errmsg);
    if~isvalid
        error(errmsg);
    end


    m3iPkg=autosar.mm.Model.getOrAddARPackage(modelM3I,pkgValue);
    assert(m3iPkg.isvalid());


    t=M3I.Transaction(modelM3I);
    m3iPkg.packagedElement.append(m3iObject);
    t.commit();


    if dialog.hasUnappliedChanges
        dialog.apply();
    end
end


