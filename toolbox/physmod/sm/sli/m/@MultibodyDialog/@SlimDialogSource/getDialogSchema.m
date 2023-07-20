function schema=getDialogSchema(hThis,type)







    hBlk=hThis.get_param('Handle');
    buildFunc=@lBuild;
    schema=buildFunc(hBlk);



    if~strcmp(type,'Simscape:Description')

        sp=schema.Items{2};

        schema.Items{2}=lOpenBlockGroup(hBlk);

        schema.Items{3}=sp;

        schema.LayoutGrid=[3,1];
        schema.RowStretch=[0,0,1];
    end
end

function openBlockGroup=lOpenBlockGroup(hBlk)
    openBlockText.Type='text';
    openBlockText.Tag='OpenBlockText';
    openBlockText.Name=DAStudio.message('Simulink:dialog:openfcnBlock');
    openBlockText.RowSpan=[1,1];
    openBlockText.ColSpan=[1,1];

    slashn=double(newline);
    blkname=strrep(get_param(hBlk,'Name'),char(slashn),' ');
    openBlockLink.Type='hyperlink';
    openBlockLink.Tag='OpenBlockLink';
    openBlockLink.Name=blkname;
    openBlockLink.ToolTip=DAStudio.message('Simulink:dialog:openBlockTooltip');
    openBlockLink.MatlabMethod='open_system';
    openBlockLink.MatlabArgs={getfullname(hBlk)};
    openBlockLink.RowSpan=[1,1];
    openBlockLink.ColSpan=[2,2];

    openBlockSpacer.Type='panel';
    openBlockSpacer.Tag='OpenBlockSpacer';
    openBlockSpacer.RowSpan=[1,1];
    openBlockSpacer.ColSpan=[3,3];

    openBlockGroup.Type='group';
    openBlockGroup.Tag='OpenBlockGroup';
    openBlockGroup.Items={openBlockText,openBlockLink,openBlockSpacer};
    openBlockGroup.LayoutGrid=[1,3];
    openBlockGroup.RowStretch=0;
    openBlockGroup.ColStretch=[0,0,1];
end

function dlgStruct=lBuild(hBlk)
    descriptionBox=l_buildDescriptionBox(hBlk);
    dlgStruct=l_wrapWithStretchPanel(descriptionBox);
end

function groupBox=l_buildDescriptionBox(hBlk)
    assert(ishandle(hBlk));


    descTitle=pm.sli.internal.cleanGroupLabel(get_param(hBlk,'MaskType'));
    descText=lGetBlockDescription(hBlk);
    descTextStruct=l_generateDescriptionTextStruct(descText);
    items={descTextStruct};
    groupBox=l_generateGroupBox(descTitle,items);

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

function widget=l_generateGroupBox(name,items)
    widget=struct(...
    'Name',{name},...
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

    dlgStruct=struct(...
    'DialogTitle',{''},...
    'Items',{{innerWidget,emptyPanel}},...
    'RowStretch',{[0,1]},...
    'LayoutGrid',{[2,1]},...
    'CloseMethod',{'closeDialogCB'},...
    'CloseMethodArgs',{{'%dialog'}},...
    'CloseMethodArgsDT',{{'handle'}},...
    'EmbeddedButtonSet',{{''}});

end

function str=lGetBlockDescription(hBlk)
    cls=get_param(hBlk,'ClassName');
    cls(1)=lower(cls(1));
    str=pm_message(['mech2:',cls,':Description']);
end

