function packageSelGrp=getSchema_packageSelGrp(hUI)








    colIdx=1;
    rowIdx=1;

    pkgSelBox.Name=DAStudio.message('Simulink:dialog:CSCUISelectPackage');
    pkgSelBox.Type='combobox';
    pkgSelBox.Tag='tPackageSelectCombo';
    pkgSelBox.ObjectMethod='selectPackage';
    pkgSelBox.MethodArgs={'%value'};
    pkgSelBox.ArgDataTypes={'mxArray'};
    pkgSelBox.Entries=hUI.PackageNames';
    pkgSelBox.Value=hUI.CurrPackage;
    pkgSelBox.Mode=1;
    pkgSelBox.DialogRefresh=1;
    pkgSelBox.RowSpan=[rowIdx,rowIdx];
    pkgSelBox.ColSpan=[colIdx,colIdx];

    colIdx=colIdx+1;

    widget=[];
    widget.Name=[' ',DAStudio.message('Simulink:dialog:CSCUILoadReadOnlyPkg')];
    widget.Type='text';
    widget.Tag='CSCBlankText';
    widget.ColSpan=[colIdx,colIdx];
    widget.Visible=hUI.isCSCRegFileReadOnly;
    readOnlyWidget=widget;





    packageSelGrp.Type='group';
    packageSelGrp.Tag='tPackageSelectGroup';
    packageSelGrp.LayoutGrid=[1,colIdx];
    packageSelGrp.ColStretch=[1,1];
    packageSelGrp.Items={pkgSelBox,readOnlyWidget};




