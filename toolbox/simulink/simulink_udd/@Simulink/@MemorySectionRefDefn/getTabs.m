function msSubTabs=getTabs(hThis,hUI)






    try
        hThis.updateRefObj;
    catch err %#ok

    end

    msSubTabs=getMSReferenceDetails(hThis,hUI);


    isRegFileReadOnly=hUI.isCSCRegFileReadOnly;
    if isRegFileReadOnly
        msSubTabs.Tabs{1}=Simulink.CSCUI.disableWidgets(msSubTabs.Tabs{1});
    end


    actualDefnObj=hThis.getRefDefnObj;


    refTabs=actualDefnObj.getMSPropDetails(hUI);

    for i=1:size(refTabs.Tabs,2)
        refTabs.Tabs{i}=Simulink.CSCUI.disableWidgets(refTabs.Tabs{i});
    end



    msSubTabs.Tabs=[msSubTabs.Tabs,refTabs.Tabs];

end





function msSubTabs=getMSReferenceDetails(hThis,hUI)






    currMSDefn=hThis;

    rowIdx=1;

    widget=[];
    widget.Name=DAStudio.message('Simulink:dialog:CSCRefDefnTabName');
    widget.Type='edit';
    widget.Tag='tmsNameEditParent2';
    widget.Value=assignOrSetEmpty(hUI,currMSDefn.Name);
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
    if isempty(currMSDefn.RefPackageName)
        currMSDefn.RefPackageName=inheritableList{1};
    end
    widget.Name=DAStudio.message('Simulink:dialog:MSRefDefnTabReferPkg');
    widget.Type='combobox';
    widget.Source=currMSDefn;
    widget.Entries=inheritableList;
    widget.Value=get(currMSDefn,'RefPackageName');
    widget.ObjectMethod='setPropAndDirty';
    widget.MethodArgs={'RefPackageName','%value',hUI,widget.Entries};
    widget.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    widget.Tag='MSRefPackageName';
    widget.RowSpan=[rowIdx,rowIdx];
    widget.ColSpan=[1,2];
    widget.Mode=1;
    widget.DialogRefresh=1;
    refPackageWidget=widget;

    rowIdx=rowIdx+1;

    filelong=processcsc('GetCSCRegFile',currMSDefn.RefPackageName);
    [filepath,filename,fileext]=fileparts(filelong);%#ok
    widget=[];
    widget.Name=DAStudio.message('Simulink:dialog:CSCRefDefnTabPkgLocation',filepath);
    widget.Type='text';
    widget.Tag='MSReferencePackageLocation';
    widget.RowSpan=[rowIdx,rowIdx];
    widget.ColSpan=[1,2];
    refPackageLocWidget=widget;

    rowIdx=rowIdx+1;

    widget=[];
    msNamesList=processcsc('GetMemorySectionNames',currMSDefn.RefPackageName);
    widget.Name=DAStudio.message('Simulink:dialog:MSRefDefnTabReferMS');
    widget.Type='combobox';
    widget.Source=currMSDefn;
    widget.Entries=msNamesList;
    widget.Value=get(currMSDefn,'RefDefnName');
    widget.ObjectMethod='setPropAndDirty';
    widget.MethodArgs={'RefDefnName','%value',hUI,widget.Entries};
    widget.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
    widget.Tag='MSRefDefnName';
    widget.Mode=1;
    widget.DialogRefresh=1;
    widget.Enabled=true;
    widget.RowSpan=[rowIdx,rowIdx];
    widget.ColSpan=[1,2];
    refMSWidget=widget;

    rowIdx=rowIdx+1;

    widget=[];
    widget.Name=' ';
    widget.Type='text';
    widget.Tag='MSBlankText';
    widget.RowSpan=[rowIdx,rowIdx];
    widget.ColSpan=[1,2];
    blankWidget=widget;

    msSubTabP.Name=DAStudio.message('Simulink:dialog:MSRefDefnDetailsTab');
    msSubTabP.Tag='tmsSubTabParent1';
    msSubTabP.LayoutGrid=[5,2];
    msSubTabP.RowStretch=[0,0,0,0,1];
    msSubTabP.Items={localNameWidget,refPackageWidget,refPackageLocWidget,refMSWidget,blankWidget};

    msSubTabs.Name='MSRefSubTabs';
    msSubTabs.Type='tab';
    msSubTabs.Tag='tmsRefSubTabs';
    msSubTabs.Tabs={msSubTabP};

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





