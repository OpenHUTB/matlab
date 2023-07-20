function dlgstruct=getCoderOptionsDlg(h,name)







    lblName.Name='Target Name:';
    lblName.Type='text';
    lblName.RowSpan=[1,1];
    lblName.ColSpan=[1,3];
    lblName.Tag=strcat('sfCoderoptsdlg_',lblName.Name);


    txtName.Name=h.Name;
    txtName.Type='text';
    txtName.RowSpan=[1,1];
    txtName.ColSpan=[4,10];
    txtName.Tag=strcat('sfCoderoptsdlg_',txtName.Name);





    flags=get(h,'CodeFlagsInfo');
    grpMain.Items={};


    for i=1:length(flags)
        flag=flags(i);
        wid.Name=flag.description;

        val=flag.value;
        if(val==-1)
            val=flag.defaultValue;
        end

        switch(flag.type)
        case 'boolean'
            wid.Type='checkbox';
        case 'enumeration'
            wid.Type='combobox';
            wid.Entries=flag.description;
        end

        wid.InitialValue=val;

        wid.Tag=int2str(i);
        grpMain.Items{i}=wid;
    end

    grpMain.Name='Coder Options';
    grpMain.Type='group';
    grpMain.RowSpan=[2,2];
    grpMain.ColSpan=[1,10];
    grpMain.Tag=strcat('sfCoderoptsdlg_',grpMain.Name);


    pnlMain.Type='panel';
    pnlMain.LayoutGrid=[2,2];
    pnlMain.Items={lblName,txtName,...
    grpMain};
    pnlMain.Tag='sfCoderoptsdlg_pnlMain';




    dlgstruct.DialogTitle=['Stateflow ',h.Name,' Coder Options'];



    dlgstruct.Items={pnlMain};

