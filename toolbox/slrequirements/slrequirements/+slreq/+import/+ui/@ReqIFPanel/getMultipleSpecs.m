function[items,grid]=getMultipleSpecs(this)


    multipleSpecsOption.Type='radiobutton';
    multipleSpecsOption.Name=getString(message('Slvnv:slreq_import:ReqIFMultipleSpecs'));
    multipleSpecsOption.Tag='ReqIFPanel_multiSpecOption';

    multipleSpecsOption.Value=slreq.import.ui.ReqIFPanel.IMPORT_SELECTED;
    multipleSpecsOption.Enabled=this.hasMultipleSpecs();
    multipleSpecsOption.Values=[slreq.import.ui.ReqIFPanel.IMPORT_SELECTED,...
    slreq.import.ui.ReqIFPanel.IMPORT_ALL_AS_ONE,...
    slreq.import.ui.ReqIFPanel.IMPORT_ALL_AS_MULTIPLE];
    multipleSpecsOption.Entries={...
    getString(message('Slvnv:slreq_import:ReqIFMultipleSpecsImportOnlySelected')),...
    getString(message('Slvnv:slreq_import:ReqIFMultipleSpecsImportAllAsOneReqSet')),...
    getString(message('Slvnv:slreq_import:ReqIFMultipleSpecsImportAllAsMultiReqSets'))};
    multipleSpecsOption.RowSpan=[2,5];
    multipleSpecsOption.ColSpan=[1,2];
    multipleSpecsOption.Mode=true;
    multipleSpecsOption.Graphical=true;
    multipleSpecsOption.MatlabMethod='slreq.import.ui.ReqIFPanel.multiSpecOption_callback';
    multipleSpecsOption.MatlabArgs={this,'%dialog'};

    specCombo.Type='combobox';
    specCombo.Tag='ReqIFPanel_specCombo';
    specCombo.Entries=this.specNames;
    specCombo.Enabled=this.hasMultipleSpecs();
    specCombo.RowSpan=[3,3];
    specCombo.ColSpan=[2,2];
    specCombo.MatlabMethod='slreq.import.ui.ReqIFPanel.specCombo_callback';
    specCombo.MatlabArgs={this,'%dialog'};


    importLinks.Type='checkbox';
    importLinks.Name=getString(message('Slvnv:slreq_import:ReqIFImportLinks'));
    importLinks.ToolTip=getString(message('Slvnv:slreq_import:ReqIFImportLinksTooltip'));
    importLinks.Tag='ReqIFPanel_importLinks';

    importLinks.Enabled=this.hasLinks;
    importLinks.Value=this.hasLinks;
    importLinks.RowSpan=[6,6];
    importLinks.ColSpan=[1,2];
    importLinks.MatlabMethod='slreq.import.ui.ReqIFPanel.importLinks_callback';
    importLinks.MatlabArgs={this,'%dialog'};

    linksGroup.Type='group';
    linksGroup.Name=getString(message('Slvnv:slreq_import:ReqIFLinks'));
    linksGroup.RowSpan=[6,7];
    linksGroup.ColSpan=[1,2];
    linksGroup.Items={importLinks};

    items.Type='panel';
    items.Name='panel';
    items.LayoutGrid=[5,5];
    items.Items={...
    multipleSpecsOption,...
    specCombo,...
    linksGroup};
    items.RowSpan=[2,2];
    items.ColSpan=[1,2];

    grid=[2,2];
end