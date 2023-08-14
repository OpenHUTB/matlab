function[items,grid]=doorsOptions(this)


    styleOption.Type='radiobutton';
    styleOption.Name=getString(message('Slvnv:slreq_import:Content'));
    styleOption.Tag='SlreqImportDlg_styleOption';
    styleOption.Value=this.style;
    styleOption.Values=[0,1];
    styleOption.Entries={...
    getString(message('Slvnv:slreq_import:OptionPlainTextExcel')),...
    getString(message('Slvnv:slreq_import:OptionRichTextExcel'))};
    styleOption.RowSpan=[1,1];
    styleOption.ColSpan=[1,1];
    styleOption.ObjectMethod='SlreqImportDlg_styleOption_callback';
    styleOption.MethodArgs={'%dialog'};
    styleOption.ArgDataTypes={'handle'};
    styleOption.Enabled=true;



    filterIntroNote.Type='text';
    filterIntroNote.Name=getString(message('Slvnv:slreq_import:DoorsRowFilterNote'));
    filterIntroNote.RowSpan=[1,1];
    filterIntroNote.ColSpan=[1,4];

    doorsFilterCheckbox.Type='checkbox';
    doorsFilterCheckbox.Name=getString(message('Slvnv:slreq_import:DoorsRowFilterRemember'));
    doorsFilterCheckbox.Tag='SlreqImportDlg_filterOption';

    moduleId=rmidoors.getCurrentObj();
    currentFilter=rmidoors.getModuleAttribute(moduleId,'rowFilter');
    if isempty(currentFilter)
        doorsFilterCheckbox.Enabled=false;
        doorsFilterCheckbox.Value=false;
        this.filterString='';
    else
        doorsFilterCheckbox.Enabled=true;
        doorsFilterCheckbox.Value=true;
        this.filterString=currentFilter;
    end

    doorsFilterCheckbox.ObjectMethod='SlreqImportDlg_filterOption_callback';
    doorsFilterCheckbox.MethodArgs={'%dialog'};
    doorsFilterCheckbox.ArgDataTypes={'handle'};
    doorsFilterCheckbox.RowSpan=[2,2];
    doorsFilterCheckbox.ColSpan=[1,2];

    currentFilterLabel.Type='text';
    if isempty(currentFilter)
        currentFilterLabel.Name=getString(message('Slvnv:slreq_import:DoorsRowFilterNone'));
        currentFilterLabel.Enabled=false;
    else
        currentFilterLabel.Name=currentFilter;
    end
    currentFilterLabel.RowSpan=[3,3];
    currentFilterLabel.ColSpan=[1,2];

    filterRefreshButton.Type='pushbutton';
    filterRefreshButton.Name=getString(message('Slvnv:slreq:Refresh'));
    filterRefreshButton.Tag='SlreqImportDlg_filterRefresh';
    filterRefreshButton.ObjectMethod='SlreqImportDlg_filterRefresh_callback';
    filterRefreshButton.MethodArgs={'%dialog'};
    filterRefreshButton.ArgDataTypes={'handle'};
    filterRefreshButton.RowSpan=[2,3];
    filterRefreshButton.ColSpan=[4,4];

    filterGroup.Type='group';
    filterGroup.Name=getString(message('Slvnv:slreq_import:DoorsRowFilter'));
    filterGroup.ToolTip=getString(message('Slvnv:slreq_import:DoorsFilterRefreshTooltip'));
    filterGroup.LayoutGrid=[3,4];
    filterGroup.Items={filterIntroNote,doorsFilterCheckbox,currentFilterLabel,filterRefreshButton};
    filterGroup.RowSpan=[2,2];
    filterGroup.ColSpan=[1,1];

    attributeMappingButton.Type='pushbutton';
    attributeMappingButton.Name=getString(message('Slvnv:slreq_import:MapAttributes'));
    attributeMappingButton.Tag='SlreqImportDlg_attributeSelector';
    attributeMappingButton.RowSpan=[1,1];
    attributeMappingButton.ColSpan=[4,4];
    attributeMappingButton.Enabled=this.isReadyForAttributeSelection();
    attributeMappingButton.ObjectMethod='SlreqImportDlg_attributeSelector_callback';
    attributeMappingButton.MethodArgs={'%dialog'};
    attributeMappingButton.ArgDataTypes={'handle'};

    attributeMappingNote.Type='text';
    attributeMappingNote.Tag='SlreqImportDlg_columnList';
    attributeMappingNote.Name=listAttributes();
    attributeMappingNote.RowSpan=[1,1];
    attributeMappingNote.ColSpan=[1,3];

    mappingGroup.Type='group';
    mappingGroup.Name=getString(message('Slvnv:slreq_import:AttributesToImport'));
    mappingGroup.LayoutGrid=[1,4];
    mappingGroup.Items={attributeMappingNote,attributeMappingButton};
    mappingGroup.RowSpan=[3,3];
    mappingGroup.ColSpan=[1,1];

    items={styleOption,filterGroup,mappingGroup};
    grid=[3,1];

    function list=listAttributes()
        if isempty(this.attributeMap)
            list=getString(message('Slvnv:slreq_import:SpecifyAttributesMapping'));
        else
            attributes=keys(this.attributeMap);
            list='';
            for i=1:length(attributes)
                list=[list,this.attributeMap(attributes{i}),', '];%#ok<AGROW>
            end
            if length(list)>44
                list=[list(1:40),'...'];
            else
                list(end-1:end)=[];
            end
        end
    end
end
