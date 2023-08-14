function group=getProjSettingsGroup(this,tag,enableGroup)





    src=this.FPGAProperties;
    curRow=0;




    switch(src.FPGAWorkflow)
    case 'Project generation'

        showGroup=(strcmpi(src.FPGAProjectGenOutput,'ISE project')&&...
        strcmpi(src.FPGAProjectType,'Create new project'))||...
        (strcmpi(src.FPGAProjectGenOutput,'Tcl script')&&...
        strcmpi(src.TclOptions,'Create new project'));

        if strcmpi(src.FPGAProjectGenOutput,'Tcl script')
            showProjFolder=false;
        else
            showProjFolder=showGroup;
        end

        showAddUserFile=showGroup;
        showProcTable=showGroup;
        enableTargetDevice=enableGroup;

    otherwise
        showGroup=true;
        showProjFolder=true;
        showAddUserFile=false;
        showProcTable=false;
        enableTargetDevice=false;
    end








    if strcmpi(src.FPGAWorkflow,'USRP2 filter customization')
        src.FPGAFamily='Spartan3';
        src.FPGADevice='xc3s2000';
        src.FPGASpeed='-5';
        src.FPGAPackage='fg456';


        deviceList=getFPGAPartList(src.FPGAFamily);
        speedList=getFPGAPartList(src.FPGAFamily,src.FPGADevice,'speed');
        packageList=getFPGAPartList(src.FPGAFamily,src.FPGADevice,'package');

    else










        deviceList=getFPGAPartList(src.FPGAFamily);
        if~any(strcmp(src.FPGADevice,deviceList))
            if~isempty(deviceList)
                src.FPGADevice=deviceList{1};
            end
            speedList=getFPGAPartList(src.FPGAFamily,src.FPGADevice,'speed');
            if~isempty(speedList)
                src.FPGASpeed=speedList{1};
            end
            packageList=getFPGAPartList(src.FPGAFamily,src.FPGADevice,'package');
            if~isempty(packageList)
                src.FPGAPackage=packageList{1};
            end
        else


            speedList=getFPGAPartList(src.FPGAFamily,src.FPGADevice,'speed');
            if~any(strcmp(src.FPGASpeed,speedList))&&~isempty(speedList)
                src.FPGASpeed=speedList{1};
            end
            packageList=getFPGAPartList(src.FPGAFamily,src.FPGADevice,'package');
            if~any(strcmp(src.FPGAPackage,packageList))&&~isempty(packageList)
                src.FPGAPackage=packageList{1};
            end
        end
    end



    curRow=curRow+1;

    prop='FPGAProjectName';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,1];
    projectNameLabel=widget;

    widget=[];
    widget.Type='edit';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[2,2];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    projectName=widget;

    projectNameLabel.Buddy=projectName.Tag;



    prop='FPGAProjectFolder';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[3,3];
    widget.Visible=showProjFolder;
    projectFolderLabel=widget;

    widget=[];
    widget.Type='edit';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[4,7];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.Visible=showProjFolder;
    projectFolder=widget;

    projectFolderLabel.Buddy=projectFolder.Tag;





    widget=[];
    widget.Name=l_GetUIString('BrowseButton');
    widget.Type='pushbutton';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[8,8];
    widget.Source=this;

    widget.Alignment=5;
    widget.Tag=[tag,'browseForProjectFolder'];
    widget.DialogRefresh=true;
    widget.Visible=showProjFolder;
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',tag,widget.Tag};
    widget.ArgDataTypes={'handle','string','string'};
    browseForFolder=widget;


    curRow=curRow+1;

    widget=[];
    widget.Name=l_GetUIString('TargetDeviceGroup');
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,8];
    targetDeviceLabel=widget;


    curRow=curRow+1;

    prop='FPGAFamily';




    widget=[];
    widget.Name=['  ',l_GetUIString(prop)];
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,1];
    FPGAFamilyLabel=widget;

    widget=[];
    widget.Type='combobox';
    widget.Entries=getFPGAPartList;
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[2,2];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Enabled=enableTargetDevice;
    FPGAFamily=widget;

    FPGAFamilyLabel.Buddy=FPGAFamily.Tag;


    prop='FPGADevice';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[3,3];
    FPGADeviceLabel=widget;

    widget=[];
    widget.Type='combobox';
    widget.Entries=deviceList;
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[4,4];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Enabled=enableTargetDevice;
    FPGADevice=widget;

    FPGADeviceLabel.Buddy=FPGADevice.Tag;


    prop='FPGASpeed';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[5,5];
    FPGASpeedLabel=widget;

    widget=[];
    widget.Type='combobox';
    widget.Entries=speedList;
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[6,6];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Enabled=enableTargetDevice;
    FPGASpeed=widget;

    FPGASpeedLabel.Buddy=FPGASpeed.Tag;


    prop='FPGAPackage';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[7,7];
    FPGAPackageLabel=widget;

    widget=[];
    widget.Type='combobox';
    widget.Entries=packageList;
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[8,8];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.Mode=true;
    widget.DialogRefresh=true;
    widget.Enabled=enableTargetDevice;
    FPGAPackage=widget;

    FPGAPackageLabel.Buddy=FPGAPackage.Tag;


    curRow=curRow+1;

    prop='UserFPGASourceFiles';

    widget=[];
    widget.Name=l_GetUIString(prop);
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,8];
    widget.Visible=showAddUserFile;
    additionalFilesLabel=widget;

    curRow=curRow+1;

    widget=[];
    widget.Type='editarea';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,7];
    widget.MinimumSize=[100,40];
    widget.Source=src;
    widget.ObjectProperty=prop;
    widget.Tag=[tag,widget.ObjectProperty];
    widget.ToolTip=l_GetUIString(prop,'_ToolTip');
    widget.Mode=true;
    widget.Visible=showAddUserFile;
    additionalFiles=widget;

    additionalFilesLabel.Buddy=additionalFiles.Tag;


    widget=[];
    widget.Name=l_GetUIString('BrowseButton');
    widget.Type='pushbutton';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[8,8];
    widget.Source=this;

    widget.Alignment=2;
    widget.Tag=[tag,'browseForUserFiles'];
    widget.DialogRefresh=true;
    widget.Visible=showAddUserFile;
    widget.ObjectMethod='dialogCallback';
    widget.MethodArgs={'%dialog',tag,widget.Tag};
    widget.ArgDataTypes={'handle','string','string'};
    browseForAddFiles=widget;


    curRow=curRow+1;

    widget=[];
    widget.Name=l_GetUIString('ProcessPropertyTable');
    widget.Type='text';
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,8];
    widget.Visible=showProcTable;
    propertySettingsLabel=widget;

    curRow=curRow+1;

    widget=this.FPGAProjectPropTableSource.CreateTableWidget;
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[1,7];
    widget.Visible=showProcTable;
    widget.ValueChangedCallback=@l_OnProjectPropTableValueChangeCB;
    widget.CurrentItemChangedCallback=@l_OnProjectPropTableFocusChangeCB;
    propertySettingsTable=widget;

    propertySettingsLabel.Buddy=propertySettingsTable.Tag;


    buttonSize=[0,0];

    widget=this.FPGAProjectPropTableSource.CreateTableOperationsWidget(buttonSize);
    widget.RowSpan=[curRow,curRow];
    widget.ColSpan=[8,8];
    widget.Visible=showProcTable;
    propertySettingsButtons=widget;



    gname='ProjSettingsGroup';

    group.Name=l_GetUIString(gname);
    group.Type='group';
    group.LayoutGrid=[curRow,8];
    group.ColStretch=[0,1,0,1,0,1,0,1];
    group.Tag=[tag,gname];
    group.Visible=showGroup;
    group.Enabled=enableGroup;
    group.Items={projectNameLabel,projectName,...
    projectFolderLabel,projectFolder,browseForFolder,...
    targetDeviceLabel,FPGAFamilyLabel,FPGAFamily,FPGADeviceLabel,...
    FPGADevice,FPGASpeedLabel,FPGASpeed,FPGAPackageLabel,FPGAPackage,...
    additionalFilesLabel,additionalFiles,browseForAddFiles,...
    propertySettingsLabel,propertySettingsTable,propertySettingsButtons,...
    };




    function l_OnProjectPropTableValueChangeCB(dlg,row,col,value)
        srcObj=dlg.getDialogSource();
        fpgaTab=DAStudio.message('HDLShared:fdhdldialog:fdhdlfpgaComponentName');
        fpgadlg=srcObj.getsubcomponent(fpgaTab);
        fpgadlg.FPGAProjectPropTableSource.OnTableValueChangeCB(dlg,row,col,value);

        function l_OnProjectPropTableFocusChangeCB(dlg,row,col)
            srcObj=dlg.getDialogSource();
            fpgaTab=DAStudio.message('HDLShared:fdhdldialog:fdhdlfpgaComponentName');
            fpgadlg=srcObj.getsubcomponent(fpgaTab);
            fpgadlg.FPGAProjectPropTableSource.OnTableFocusChangeCB(dlg,row,col);


            function str=l_GetUIString(key,postfix)
                if nargin<2
                    postfix='_Name';
                end
                str=DAStudio.message(['EDALink:FPGAUI:',key,postfix]);
