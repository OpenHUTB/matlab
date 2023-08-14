function dlgstruct=getDialogSchema(h,schemaName)%#ok<INUSD>




    tag='ConfigSet_TargetBrowser_';











    col_1_title=DAStudio.message('RTW:buildProcess:tlcBrowseFile');
    col_2_title=DAStudio.message('RTW:buildProcess:tlcBrowseDescription');
    lbl.Name=[col_1_title,blanks(h.column1Width-length(col_1_title)),col_2_title];
    fullname.Name=DAStudio.message('RTW:buildProcess:tlcBrowseFullName');
    title=DAStudio.message('RTW:buildProcess:tlcBrowseTitle');


    lbl.Type='text';
    lbl.Alignment=1;
    lbl.FontFamily='Courier';



    list.Type='listbox';
    list.Tag=[tag,'list'];
    list.Entries=get(h,'tlclist');
    list.ObjectProperty='tlclist_selected';
    list.MultiSelect=0;
    list.FontFamily='Courier';
    list.Mode=1;
    list.DialogRefresh=1;
















    tlcfiles=get(h,'tlcfiles');
    filesIdx=get(h,'tlcfiles_selected');
    listIdx=get(h,'tlclist_selected');
    if listIdx>-1




        listIdx=listIdx+1;
        realListIdx=0;
        for idx=1:length(tlcfiles)
            if~tlcfiles(idx).isObsolete
                realListIdx=realListIdx+1;
                if listIdx==realListIdx
                    break
                end
            end
        end
        set(h,'tlcfiles_selected',idx);
        selected=tlcfiles(idx);
    elseif filesIdx>-1





        selected=tlcfiles(filesIdx);
    else




        selected=[];
    end


    fullname.Type='text';
    fullname.Tag=[tag,'FullName'];


    if~isempty(selected)
        fullnameCont.Name=selected.fullName;
    else
        fullnameCont.Name='';
    end
    fullnameCont.Type='text';
    fullnameCont.Tag=[tag,'FullNameContent'];


    hParent=get(h,'parentSrc');
    model=hParent.getModel;
    if~isempty(model)
        title=[title,' ',get_param(model,'Name')];
    end


    lbl.RowSpan=[1,1];
    lbl.ColSpan=[1,2];
    list.RowSpan=[2,2];
    list.ColSpan=[1,2];
    fullname.RowSpan=[3,3];
    fullname.ColSpan=[1,1];
    fullnameCont.RowSpan=[3,3];
    fullnameCont.ColSpan=[2,2];
    dlgstruct.DialogTitle=title;
    dlgstruct.Items={lbl,list,fullname,fullnameCont};
    dlgstruct.LayoutGrid=[5,2];
    dlgstruct.RowStretch=[0,1,0,0,0];
    dlgstruct.ColStretch=[0,1];
    dlgstruct.PreApplyCallback='rtwprivate';
    dlgstruct.PreApplyArgs={'targetBrowserCloseCB','%dialog','PreApply'};
    dlgstruct.SmartApply=0;
    dlgstruct.HelpMethod='helpview([docroot ''/toolbox/rtw/helptargets.map''],''systargfilebrowser'')';
    dlgstruct.IsScrollable=false;
    dlgstruct.Sticky=true;
end
