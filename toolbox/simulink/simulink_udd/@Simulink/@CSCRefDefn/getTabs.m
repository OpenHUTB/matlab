function cscSubTabs=getTabs(hThis,hUI)






    try
        hThis.updateRefObj;
    catch err %#ok

    end

    cscSubTabs=getCSCReferenceDetails(hThis,hUI);


    actualDefnObj=hThis.getRefDefnObj;


    isRegFileReadOnly=hUI.isCSCRegFileReadOnly;
    if isRegFileReadOnly
        cscSubTabs.Tabs{1}=Simulink.CSCUI.disableWidgets(cscSubTabs.Tabs{1});
    end


    refTabs=actualDefnObj.getCSCPropDetails(hUI);

    for i=1:size(refTabs.Tabs,2)
        refTabs.Tabs{i}=Simulink.CSCUI.disableWidgets(refTabs.Tabs{i});
    end

    cscSubTabs.Tabs=[cscSubTabs.Tabs,refTabs.Tabs];

end





function cscSubTabs=getCSCReferenceDetails(hThis,hUI)






    currCSCDefn=hThis;

    rowIdx=1;

    widget=[];
    widget.Name=DAStudio.message('Simulink:dialog:CSCRefDefnTabName');
    widget.Type='edit';
    widget.Tag='tcscNameEditParent2';
    widget.Value=assignOrSetEmpty(hUI,currCSCDefn.Name);
    widget.Source=hUI;
    widget.ObjectMethod='nameDefn';
    widget.MethodArgs={'%value'};
    widget.ArgDataTypes={'mxArray'};
    widget.RowSpan=[rowIdx,rowIdx];
    widget.ColSpan=[1,2];
    widget.Mode=1;
    widget.DialogRefresh=1;
    localNameWidget=widget;

    rowIdx=rowIdx+1;

    widget=[];
    inheritableList=removePkgFromList(hUI.PackageNames,hUI.CurrPackage);
    if isempty(currCSCDefn.RefPackageName)
        currCSCDefn.RefPackageName=inheritableList{1};
    end
    widget.Name=DAStudio.message('Simulink:dialog:CSCRefDefnTabReferPkg');
    widget.Type='combobox';
    widget.Source=currCSCDefn;
    widget.Entries=inheritableList;
    widget.Value=get(currCSCDefn,'RefPackageName');
    widget.ObjectMethod='setPropAndDirty';
    widget.MethodArgs={'RefPackageName','%value',hUI,widget.Entries};
    widget.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    widget.Tag='CSCRefPackageName';
    widget.RowSpan=[rowIdx,rowIdx];
    widget.ColSpan=[1,2];
    widget.Mode=1;
    widget.DialogRefresh=1;
    refPackageWidget=widget;

    rowIdx=rowIdx+1;

    filelong=processcsc('GetCSCRegFile',currCSCDefn.RefPackageName);
    [filepath,filename,fileext]=fileparts(filelong);%#ok
    widget=[];
    widget.Name=DAStudio.message('Simulink:dialog:CSCRefDefnTabPkgLocation',filepath);
    widget.Type='text';
    widget.Tag='CSCReferencePackageLocation';
    widget.RowSpan=[rowIdx,rowIdx];
    widget.ColSpan=[1,2];
    refPackageLocWidget=widget;

    rowIdx=rowIdx+1;

    widget=[];
    cscNamesList=processcsc('GetCSCNames',currCSCDefn.RefPackageName);
    widget.Name=DAStudio.message('Simulink:dialog:CSCRefDefnTabReferCSC');
    widget.Type='combobox';
    widget.Source=currCSCDefn;
    widget.Entries=cscNamesList;
    widget.Value=get(currCSCDefn,'RefDefnName');
    widget.ObjectMethod='setPropAndDirty';
    widget.MethodArgs={'RefDefnName','%value',hUI,widget.Entries};
    widget.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    widget.Tag='CSCRefDefnName';
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Enabled=true;
    widget.RowSpan=[rowIdx,rowIdx];
    widget.ColSpan=[1,2];
    refCSCWidget=widget;

    rowIdx=rowIdx+1;

    widget=[];
    widget.Name=' ';
    widget.Type='text';
    widget.Tag='CSCBlankText';
    widget.RowSpan=[rowIdx,rowIdx];
    widget.ColSpan=[1,2];
    blankWidget=widget;

    cscSubTabP.Name=DAStudio.message('Simulink:dialog:CSCRefDefnDetailsTab');
    cscSubTabP.Tag='tcscSubTabParent1';
    cscSubTabP.LayoutGrid=[5,2];
    cscSubTabP.RowStretch=[0,0,0,0,1];
    cscSubTabP.Items={localNameWidget,refPackageWidget,refPackageLocWidget,refCSCWidget,blankWidget};

    cscSubTabs.Name='CSCRefSubTabs';
    cscSubTabs.Type='tab';
    cscSubTabs.Tag='tcscRefSubTabs';
    cscSubTabs.Tabs={cscSubTabP};
end




function list=removePkgFromList(packageList,pkgName)


    if(find(strcmp(packageList,pkgName)))
        [inds]=find(~strcmp(packageList,pkgName));
        list=packageList(inds);
    else
        list=[];
        list{1}='None';
    end

end


