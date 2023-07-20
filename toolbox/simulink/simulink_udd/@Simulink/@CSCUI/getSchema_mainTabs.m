function mainTabs=getSchema_mainTabs(hUI)















    msListGroup=getMSListGroup(hUI);


    msSubTabs=[];
    currMSDefn=getCurrMSDefn(hUI);
    if(~isempty(currMSDefn))
        msSubTabs=currMSDefn.getTabs(hUI);
    end

    msTab.Name=DAStudio.message('Simulink:dialog:CSCUIMemorySectionTab');
    msTab.Tag='tmsTab';
    msTab.LayoutGrid=[2,1];
    msListGroup.RowSpan=[1,1];
    msListGroup.ColSpan=[1,1];
    msSubTabs.RowSpan=[2,2];
    msSubTabs.ColSpan=[1,1];
    msTab.Items={msListGroup,msSubTabs};







    cscListGroup=getCSCListGroup(hUI);


    cscSubTabs=[];
    currCSCDefn=getCurrCSCDefn(hUI);
    if(~isempty(currCSCDefn))
        cscSubTabs=currCSCDefn.getTabs(hUI);
    end

    cscTab.Name=DAStudio.message('Simulink:dialog:CSCUICustomStorageClassTab');
    cscTab.Tag='tcscTab';
    cscTab.LayoutGrid=[2,1];
    cscListGroup.RowSpan=[1,1];
    cscListGroup.ColSpan=[1,1];
    cscSubTabs.RowSpan=[2,2];
    cscSubTabs.ColSpan=[1,1];
    cscTab.Items={cscListGroup,cscSubTabs};







    mainTabs.Name=DAStudio.message('Simulink:dialog:CSCUIMainConfiguration');
    mainTabs.Type='tab';
    mainTabs.Tag='tMainTabs';
    mainTabs.Tabs={cscTab,msTab};
    mainTabs.ActiveTab=hUI.MainActiveTab;
    mainTabs.TabChangedCallback='cscuicallback';

end




function cscListGroup=getCSCListGroup(hUI)


    currCSCDefn=getCurrCSCDefn(hUI);









    cscList.Entries=[];
    for i=1:length(hUI.AllDefns{1})
        if isempty(hUI.AllDefns{1}(i).Name)

            hUI.AllDefns{1}(i).Name='(empty)';
        end
        cscList.Entries=[cscList.Entries,{hUI.AllDefns{1}(i).Name}];
    end








    cscList.Name=DAStudio.message('Simulink:dialog:CSCUICSCDefnListName');
    cscList.Type='listbox';
    cscList.Tag='tcscList';

    cscList.Value=hUI.Index(1);
    cscList.Source=hUI;
    cscList.ObjectMethod='setIndex';
    cscList.MethodArgs={'%value'};
    cscList.ArgDataTypes={'mxArray'};
    cscList.MultiSelect=0;
    cscList.Mode=1;
    cscList.DialogRefresh=1;





    cscNewButton.Name=DAStudio.message('Simulink:dialog:CSCUINewDefn');
    cscNewButton.Type='pushbutton';
    cscNewButton.Tag='tcscNewButton';
    cscNewButton.Source=hUI;
    cscNewButton.ObjectMethod='newDefn';
    cscNewButton.MethodArgs={cscNewButton.Tag};
    cscNewButton.ArgDataTypes={'string'};
    cscNewButton.Mode=1;
    cscNewButton.DialogRefresh=1;





    cscNewRefButton.Name=DAStudio.message('Simulink:dialog:CSCUINewRef');
    cscNewRefButton.Type='pushbutton';
    cscNewRefButton.Tag='tcscNewButtonRef';
    cscNewRefButton.Source=hUI;
    cscNewRefButton.ObjectMethod='newDefn';
    cscNewRefButton.MethodArgs={cscNewRefButton.Tag};
    cscNewRefButton.ArgDataTypes={'string'};
    cscNewRefButton.Mode=1;
    cscNewRefButton.DialogRefresh=1;






    cscCopyButton.Name=DAStudio.message('Simulink:dialog:CSCUICopyDefn');
    cscCopyButton.Type='pushbutton';
    cscCopyButton.Tag='tcscCopyButton';
    cscCopyButton.Source=hUI;
    cscCopyButton.ObjectMethod='copyDefn';
    cscCopyButton.Mode=1;
    cscCopyButton.DialogRefresh=1;





    cscUpButton.Name=DAStudio.message('Simulink:dialog:CSCUIUpDefn');
    cscUpButton.Type='pushbutton';
    cscUpButton.Tag='tcscUpButton';
    cscUpButton.Source=hUI;
    cscUpButton.ObjectMethod='upDefn';
    cscUpButton.Mode=1;
    cscUpButton.DialogRefresh=1;
    cscUpButton.Enabled=double(hUI.Index(1)>=2);






    cscDownButton.Name=DAStudio.message('Simulink:dialog:CSCUIDownDefn');
    cscDownButton.Type='pushbutton';
    cscDownButton.Tag='tcscDownButton';
    cscDownButton.Source=hUI;
    cscDownButton.ObjectMethod='downDefn';
    cscDownButton.Mode=1;
    cscDownButton.DialogRefresh=1;
    cscDownButton.Enabled=...
    double((hUI.Index(1)+1<length(hUI.AllDefns{1}))&&...
    (hUI.Index(1)~=0));





    cscRemButton.Name=DAStudio.message('Simulink:dialog:CSCUIRemoveDefn');
    cscRemButton.Type='pushbutton';
    cscRemButton.Tag='tcscRemoveButton';
    cscRemButton.Source=hUI;
    cscRemButton.ObjectMethod='removeDefn';
    cscRemButton.Mode=1;
    cscRemButton.DialogRefresh=1;
    cscRemButton.Enabled=double(~isempty(currCSCDefn)&&...
    (hUI.Index(1)~=0));





    cscValidButton.Name=DAStudio.message('Simulink:dialog:CSCUIValidateDefn');
    cscValidButton.Type='pushbutton';
    cscValidButton.Tag='tcscValidButton';
    cscValidButton.Source=hUI;
    cscValidButton.ObjectMethod='validDefn';
    cscValidButton.Mode=1;
    cscValidButton.DialogRefresh=1;
    cscValidButton.Enabled=double(~isempty(currCSCDefn));





    cscListGroup.Type='group';
    cscListGroup.Tag='tcscListGroup';
    cscListGroup.LayoutGrid=[7,2];
    cscListGroup.ColStretch=[1,0];

    cscList.RowSpan=[1,7];
    cscList.ColSpan=[1,1];
    cscNewButton.RowSpan=[1,1];
    cscNewButton.ColSpan=[2,2];
    cscNewRefButton.RowSpan=[2,2];
    cscNewRefButton.ColSpan=[2,2];
    cscCopyButton.RowSpan=[3,3];
    cscCopyButton.ColSpan=[2,2];
    cscUpButton.RowSpan=[4,4];
    cscUpButton.ColSpan=[2,2];
    cscDownButton.RowSpan=[5,5];
    cscDownButton.ColSpan=[2,2];
    cscRemButton.RowSpan=[6,6];
    cscRemButton.ColSpan=[2,2];
    cscValidButton.RowSpan=[7,7];
    cscValidButton.ColSpan=[2,2];


    isRegFileReadOnly=hUI.isCSCRegFileReadOnly;
    if isRegFileReadOnly
        cscNewButton.Enabled=false;
        cscNewRefButton.Enabled=false;
        cscCopyButton.Enabled=false;
        cscUpButton.Enabled=false;
        cscDownButton.Enabled=false;
        cscRemButton.Enabled=false;
        cscValidButton.Enabled=false;
    end

    cscListGroup.Items={...
    cscList,...
    cscNewButton,...
    cscNewRefButton,...
    cscCopyButton,...
    cscUpButton,...
    cscDownButton,...
    cscRemButton,...
    cscValidButton,...
    };

end


function msListGroup=getMSListGroup(hUI)


    ToolTip_MS=sprintf('%s\n%s\n%s\n',...
    'Memory sections may be applied to custom storage class data, ',...
    'functions and data generated for the model, or ',...
'functions and data generated for a subsystem.'...
    );

    currMSDefn=getCurrMSDefn(hUI);









    msList.Entries=[];
    for i=1:length(hUI.AllDefns{2})
        if isempty(hUI.AllDefns{2}(i).Name)

            hUI.AllDefns{2}(i).Name='(empty)';
        end
        msList.Entries=[msList.Entries,{hUI.AllDefns{2}(i).Name}];
    end





    msList.Name=DAStudio.message('Simulink:dialog:CSCUIMSDefnListName');
    msList.Type='listbox';
    msList.Tag='tmsList';

    msList.Value=hUI.Index(2);
    msList.Source=hUI;
    msList.ObjectMethod='setIndex';
    msList.MethodArgs={'%value'};
    msList.ArgDataTypes={'mxArray'};
    msList.MultiSelect=0;
    msList.Mode=1;
    msList.DialogRefresh=1;
    msList.ToolTip=ToolTip_MS;





    msNewButton.Name=DAStudio.message('Simulink:dialog:CSCUINewDefn');
    msNewButton.Type='pushbutton';
    msNewButton.Tag='tmsNewButton';
    msNewButton.Source=hUI;
    msNewButton.ObjectMethod='newDefn';
    msNewButton.MethodArgs={msNewButton.Tag};
    msNewButton.ArgDataTypes={'string'};
    msNewButton.Mode=1;
    msNewButton.DialogRefresh=1;





    msNewRefButton.Name=DAStudio.message('Simulink:dialog:CSCUINewRef');
    msNewRefButton.Type='pushbutton';
    msNewRefButton.Tag='tmsNewButtonRef';
    msNewRefButton.Source=hUI;
    msNewRefButton.ObjectMethod='newDefn';
    msNewRefButton.MethodArgs={msNewRefButton.Tag};
    msNewRefButton.ArgDataTypes={'string'};
    msNewRefButton.Mode=1;
    msNewRefButton.DialogRefresh=1;





    msCopyButton.Name=DAStudio.message('Simulink:dialog:CSCUICopyDefn');
    msCopyButton.Type='pushbutton';
    msCopyButton.Tag='tmsCopyButton';
    msCopyButton.Source=hUI;
    msCopyButton.ObjectMethod='copyDefn';
    msCopyButton.Mode=1;
    msCopyButton.DialogRefresh=1;





    msUpButton.Name=DAStudio.message('Simulink:dialog:CSCUIUpDefn');
    msUpButton.Type='pushbutton';
    msUpButton.Tag='tmsUpButton';
    msUpButton.Source=hUI;
    msUpButton.ObjectMethod='upDefn';
    msUpButton.Mode=1;
    msUpButton.DialogRefresh=1;
    msUpButton.Enabled=double(hUI.Index(2)>=2);






    msDownButton.Name=DAStudio.message('Simulink:dialog:CSCUIDownDefn');
    msDownButton.Type='pushbutton';
    msDownButton.Tag='tmsDownButton';
    msDownButton.Source=hUI;
    msDownButton.ObjectMethod='downDefn';
    msDownButton.Mode=1;
    msDownButton.DialogRefresh=1;
    msDownButton.Enabled=double(...
    (hUI.Index(2)+1<length(hUI.AllDefns{2}))&&...
    (hUI.Index(2)~=0));





    msRemButton.Name=DAStudio.message('Simulink:dialog:CSCUIRemoveDefn');
    msRemButton.Type='pushbutton';
    msRemButton.Tag='tmsRemoveButton';
    msRemButton.Source=hUI;
    msRemButton.ObjectMethod='removeDefn';
    msRemButton.Mode=1;
    msRemButton.DialogRefresh=1;
    msRemButton.Enabled=double(~isempty(currMSDefn)&&...
    (hUI.Index(2)~=0));





    msValidButton.Name=DAStudio.message('Simulink:dialog:CSCUIValidateDefn');
    msValidButton.Type='pushbutton';
    msValidButton.Tag='tmsValidButton';
    msValidButton.Source=hUI;
    msValidButton.ObjectMethod='validDefn';
    msValidButton.Mode=1;
    msValidButton.DialogRefresh=1;
    msValidButton.Enabled=double(~isempty(currMSDefn));





    msListGroup.Type='group';
    msListGroup.Tag='tmsListGroup';
    msListGroup.LayoutGrid=[7,2];
    msListGroup.ColStretch=[1,0];

    msList.RowSpan=[1,7];
    msList.ColSpan=[1,1];
    msNewButton.RowSpan=[1,1];
    msNewButton.ColSpan=[2,2];
    msNewRefButton.RowSpan=[2,2];
    msNewRefButton.ColSpan=[2,2];
    msCopyButton.RowSpan=[3,3];
    msCopyButton.ColSpan=[2,2];
    msUpButton.RowSpan=[4,4];
    msUpButton.ColSpan=[2,2];
    msDownButton.RowSpan=[5,5];
    msDownButton.ColSpan=[2,2];
    msRemButton.RowSpan=[6,6];
    msRemButton.ColSpan=[2,2];
    msValidButton.RowSpan=[7,7];
    msValidButton.ColSpan=[2,2];


    isRegFileReadOnly=hUI.isCSCRegFileReadOnly;
    if isRegFileReadOnly
        msNewButton.Enabled=false;
        msNewRefButton.Enabled=false;
        msCopyButton.Enabled=false;
        msUpButton.Enabled=false;
        msDownButton.Enabled=false;
        msRemButton.Enabled=false;
        msValidButton.Enabled=false;
    end

    msListGroup.Items={...
    msList,...
    msNewButton,...
    msNewRefButton,...
    msCopyButton,...
    msUpButton,...
    msDownButton,...
    msRemButton,...
    msValidButton,...
    };

end


