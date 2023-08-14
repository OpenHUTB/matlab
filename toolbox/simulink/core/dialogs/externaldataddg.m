function dlgstruct=externaldataddg(hObj)



    model=hObj.getParent;
    if isa(model,"DAStudio.DAObjectProxy")
        model=model.getMCOSObjectReference;
    end

    [items,row,cols]=modelddg_data(model,true);
    dlgstruct.Items=items;

    row=row+1;
    dataSpacer.Name='';
    dataSpacer.Type='text';
    dataSpacer.ColSpan=[1,1];
    dataSpacer.RowSpan=[row,row];
    dlgstruct.Items{end+1}=dataSpacer;

    dlgstruct.RowStretch=zeros(1,row);
    dlgstruct.RowStretch(row)=1;
    dlgstruct.LayoutGrid=[row,cols];

    dlgstruct.DialogTitle=[model.getFullName(),': ',hObj.getDisplayLabel];

    if slfeature('SLDataDictionaryMigrateUI')>0
        ddFunction='link';
    else
        ddFunction='auto';
    end

    dlgstruct.PreApplyCallback='modelddg_data_cb';
    dlgstruct.PreApplyArgs={'%dialog','preapply',model,ddFunction};

    dlgstruct.PostApplyCallback='modelddg_data_cb';
    dlgstruct.PostApplyArgs={'%dialog','postapply',model};






end
