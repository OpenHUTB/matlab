function dlgstruct=getDialogSchema(h,schemaName)







    widget1.Name='Mat file logging';
    widget1.Type='checkbox';
    widget1.ObjectProperty='MatFileLogging';
    widget1.Mode=1;

    myTargetName='Sample Target';
    myItems={widget1};






    commonOptions=getCommonOptionDialog(h,schemaName);


    tab1.Name='Common target options';
    tab1.Items={commonOptions};


    tab2.Name='Target specific options';
    tab2.Items=myItems;

    tabs.Name='tab';
    tabs.Type='tab';
    tabs.Tabs={tab1,tab2};


    if strcmp(schemaName,'tab')
        dlgstruct.Name=myTargetName;
        dlgstruct.nTabs=2;
        dlgstruct.Tabs={tab1,tab2};
    else
        dlgstruct.DialogTitle='Target';
        dlgstruct.Items={tabs};
    end

