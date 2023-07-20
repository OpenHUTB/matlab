function dlgstruct=connectionelementddg(h,name)











    rowIdx=1;
    nameWidget.Name=DAStudio.message('Simulink:dialog:StructelementNameLblName');
    nameWidget.Type='edit';
    nameWidget.RowSpan=[rowIdx,rowIdx];
    nameWidget.ColSpan=[1,4];
    nameWidget.Tag='name_tag';
    nameWidget.ObjectProperty='Name';

    openDialogs=DAStudio.ToolRoot.getOpenDialogs;
    thisDialog=[];
    dlgTitle=[class(h),': ',name];
    for i=1:numel(openDialogs)
        if strcmp(openDialogs(i).getTitle,dlgTitle)
            thisDialog=openDialogs(i);
            break;
        end
    end


    rowIdx=rowIdx+2;


    physmodHyperlink.Name=DAStudio.message('Simulink:busEditor:SimscapeDomainsHyperLink');
    physmodHyperlink.Type='hyperlink';
    physmodHyperlink.Tag='physmodHyperlink';
    physmodHyperlink.MatlabMethod='helpview';
    physmodHyperlink.MatlabArgs={'simscape','DomainLineStyles'};
    physmodHyperlink.RowSpan=[rowIdx,rowIdx];
    physmodHyperlink.ColSpan=[1,4];
    physmodHyperlink.Enabled=true;
    physmodHyperlink.ToolTip=DAStudio.message('Simulink:busEditor:SimscapeDomainsHyperLinkTooltip');
    physmodHyperlink.Alignment=1;


    rowIdx=rowIdx+1;

    descVal.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    descVal.Type='editarea';
    descVal.RowSpan=[rowIdx,rowIdx];
    descVal.ColSpan=[1,4];
    descVal.Tag='description_tag';
    descVal.ObjectProperty='Description';


    dtaOn=false;
    dataTypeItems.supportsConnectionType=true;
    dataTypeItems.supportsConnectionBusType=true;
    if~isempty(thisDialog)
        dtaOn=thisDialog.isVisible('typetag|UDTDataTypeAssistGrp');
    end


    typeTag='typetag';
    dataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(h,...
    'Type',...
    [DAStudio.message('Simulink:busEditor:PropType'),':'],...
    typeTag,...
    h.Type,...
    dataTypeItems,...
    dtaOn);
    dataTypeGroup.RowSpan=[2,2];
    dataTypeGroup.ColSpan=[1,4];

    dataTypeGroupItems=dataTypeGroup.Items;
    DTAGroupIdx=strcmp(cellfun(@(elem)elem.Tag,dataTypeGroupItems,'UniformOutput',false),[typeTag,'|UDTDataTypeAssistGrp']);
    dataTypeGroup.Items{DTAGroupIdx}.Name=erase(dataTypeGroup.Items{DTAGroupIdx}.Name,'Data ');
    DTAOpenIdx=strcmp(cellfun(@(elem)elem.Tag,dataTypeGroupItems,'UniformOutput',false),[typeTag,'|UDTShowDataTypeAssistBtn']);
    dataTypeGroup.Items{DTAOpenIdx}.ToolTip=erase(dataTypeGroup.Items{DTAOpenIdx}.ToolTip,'data ');
    DTACloseIdx=strcmp(cellfun(@(elem)elem.Tag,dataTypeGroupItems,'UniformOutput',false),[typeTag,'|UDTHideDataTypeAssistBtn']);
    dataTypeGroup.Items{DTACloseIdx}.ToolTip=erase(dataTypeGroup.Items{DTACloseIdx}.ToolTip,'data ');















    tab1.Name=DAStudio.message('Simulink:dialog:DataTab1Prompt');
    tab1.LayoutGrid=[rowIdx,4];
    tab1.RowStretch=[zeros(1,rowIdx-1),1];
    tab1.ColStretch=[0,1,0,1];
    tab1.Items={nameWidget,dataTypeGroup,physmodHyperlink,descVal};
    tab1.Tag='TabOne';









    [grpAdditional,tab2]=get_additional_prop_grp(h,'ConnectionElement','TabTwo');




    dlgstruct.DialogTitle=dlgTitle;



    if~isempty(grpAdditional.Items)
        tabcont.Type='tab';
        tabcont.Tabs={tab1,tab2};
        tabcont.Tag='TabWhole';
        dlgstruct.Items={tabcont};
    else

        dlgstruct.Items=tab1.Items;
        dlgstruct.LayoutGrid=tab1.LayoutGrid;
        dlgstruct.RowStretch=tab1.RowStretch;
        dlgstruct.ColStretch=tab1.ColStretch;
    end


    dlgstruct.Items=remove_duplicate_widget_tags(dlgstruct.Items);

    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_connection_element'};

    dlgstruct.PreApplyCallback='connectionelementddg_cb';
    dlgstruct.PreApplyArgs={'%dialog','doApply'};
    dlgstruct.MinimalApply=true;
end




