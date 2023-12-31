function dlgStruct=nesl_buildslimdialogschema(hThis)





    hBlk=pmsl_getdoublehandle(hThis.BlockHandle);

    if simscape.engine.sli.internal.iscomponentblock(hBlk)
        hCompChooser=simscape.internal.dialog.ComponentChoice(hBlk);
        dlgStruct=hCompChooser.getDialogSchema();
        return
    else
        descriptionBox=l_buildDescriptionBox(hBlk);
    end

    dlgStruct=l_wrapWithStretchPanel(descriptionBox);

end

function groupBox=l_buildDescriptionBox(hBlk)


    [descTitle,descText]=nesl_getblockdescription(hBlk);
    descTextStruct=l_generateDescriptionTextStruct(descText);

    if l_hasHyperlink(hBlk)
        items={descTextStruct,l_generateHyperlink(hBlk)};
    else
        items={descTextStruct};
    end

    groupBox=l_generateGroupBox(descTitle,items);

end





function hasHyperlink=l_hasHyperlink(hBlk)

    hasHyperlink=nesl_showsourcewidget(hBlk);

end





function widget=l_generateDescriptionTextStruct(text)
    widget=struct(...
    'Name',{text},...
    'Type',{'text'},...
    'WordWrap',{true},...
    'MinimumSize',{[240,1]},...
    'RowSpan',{[1,1]},...
    'ColSpan',{[1,2]},...
    'Tag',{'ComponentDescription'});
end

function widget=l_generateHyperlink(hBlk)
    name=getString(message('physmod:ne_sli:dialog:OpenSourceString'));

    widget=struct(...
    'Name',{name},...
    'Type',{'hyperlink'},...
    'RowSpan',{[2,2]},...
    'ColSpan',{[1,1]},...
    'MatlabMethod',{'simscape.internal.viewsource'},...
    'MatlabArgs',{{hBlk}},...
    'Tag',{'ViewSource'});
end

function widget=l_generateGroupBox(name,items)
    widget=struct(...
    'Name',{pm.sli.internal.cleanGroupLabel(name)},...
    'Type',{'group'},...
    'RowSpan',{[1,1]},...
    'ColSpan',{[1,1]},...
    'LayoutGrid',{[2,2]},...
    'ColStretch',{[0,1]},...
    'Items',{items},...
    'Tag',{'ComponentDescriptionGroup'});
end

function dlgStruct=l_wrapWithStretchPanel(innerWidget)

    emptyPanel.Type='panel';

    outerBox=struct(...
    'Name',{''},...
    'Type',{'panel'},...
    'Items',{{innerWidget,emptyPanel}},...
    'RowStretch',{[0,1]},...
    'LayoutGrid',{[2,1]});

    panel=struct(...
    'Name',{''},...
    'Type',{'panel'},...
    'Items',{{outerBox}},...
    'LayoutGrid',{[1,1]});

    dlgStruct=struct(...
    'DialogTitle',{''},...
    'Items',{{panel}},...
    'CloseMethod',{'closeDialogCB'},...
    'CloseMethodArgs',{{'%dialog'}},...
    'CloseMethodArgsDT',{{'handle'}},...
    'EmbeddedButtonSet',{{''}});

end
