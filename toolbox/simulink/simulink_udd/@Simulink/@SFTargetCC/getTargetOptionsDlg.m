function dlgstruct=getTargetOptionsDlg(h,name)







    lblName.Name='Target Name:';
    lblName.Type='text';
    lblName.RowSpan=[1,1];
    lblName.ColSpan=[1,3];
    lblName.Tag=strcat('sfTargetoptsdlg_',lblName.Name);


    txtName.Name=h.Name;
    txtName.Type='text';
    txtName.RowSpan=[1,1];
    txtName.ColSpan=[4,10];
    txtName.Tag=strcat('sfTargetoptsdlg_',txtName.Name);








    item1.Name='Custom code included at the top of generated code';
    item1.Type='editarea';
    item1.ObjectProperty='CustomCode';
    item1.Tag=strcat('sfTargetoptsdlg_',item1.Name);

    item2.Name='Custom include directory';
    item2.Type='editarea';
    item2.ObjectProperty='UserIncludeDirs';
    item2.Tag=strcat('sfTargetoptsdlg_',item2.Name);

    item3.Name='Custom source files';
    item3.Type='editarea';
    item3.ObjectProperty='UserSources';
    item3.Tag=strcat('sfTargetoptsdlg_',item3.Name);

    item4.Name='Custom libraries';
    item4.Type='editarea';
    item4.ObjectProperty='UserLibraries';
    item4.Tag=strcat('sfTargetoptsdlg_',item4.Name);

    item5.Name='Code generation directory';
    item5.Type='editarea';
    item5.ObjectProperty='CodegenDirectory';
    item5.Tag=strcat('sfTargetoptsdlg_',item5.Name);




    tab1.Name='Include Code';
    tab1.Items={item1};


    tab2.Name='Include Path';
    tab2.Items={item2};


    tab3.Name='Source Files';
    tab3.Items={item3};


    tab4.Name='Libraries';
    tab4.Items={item4};


    tab5.Name='Code Generation';
    tab5.Items={item5};





    tabMain.Name='tabContainer';
    tabMain.Type='tab';
    tabMain.RowSpan=[2,2];
    tabMain.ColSpan=[1,10];
    tabMain.Tabs={tab1,tab2,tab3,tab4,tab5};
    tabMain.Tag=strcat('sfTargetoptsdlg_',tabMain.Name);




    pnlMain.Type='panel';
    pnlMain.LayoutGrid=[2,10];
    pnlMain.Items={lblName,txtName,...
    tabMain};





    dlgstruct.DialogTitle=['Stateflow ',h.Name,' Target Options'];
    dlgstruct.Items={pnlMain};

