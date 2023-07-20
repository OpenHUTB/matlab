function[items,grid]=getMappingOptions(this,srcDoc)


    this.errorDetails='';


    this.mappingMgr=slreq.app.MappingFileManager.getInstance();



    [mappingInfo,this.errorDetails]=this.mappingMgr.detectMapping(srcDoc);

    this.hasLinks=false;
    if~isempty(mappingInfo)

        mappingName=mappingInfo.name;
        this.specNames=mappingInfo.specNames;
        if length(this.specNames)>1

            this.selectedSpec=this.specNames{1};
        end
        this.hasLinks=mappingInfo.hasLinks;
    end

    allMappings=this.mappingMgr.getAllMappings();


    this.mappingFile=mappingInfo.fullpath;

    mappingDesc=this.getMappingInfoDesc(mappingInfo);

    mappingSpacer1.Type='text';
    mappingSpacer1.Tag='ReqIFPanel_mappingSpacer1';
    mappingSpacer1.Name=getString(message('Slvnv:slreq_import:ReqIFSourceTool'));
    mappingSpacer1.Alignment=7;
    mappingSpacer1.RowSpan=[1,1];
    mappingSpacer1.ColSpan=[1,1];

    mappingFile.Type='combobox';
    mappingFile.Tag='ReqIFPanel_mappingFile';
    mappingFile.RowSpan=[1,1];
    mappingFile.ColSpan=[2,4];
    mappingFile.Mode=true;
    mappingFile.Entries=allMappings;
    mappingFile.Value=mappingName;
    mappingFile.Editable=true;
    mappingFile.MatlabMethod='slreq.import.ui.ReqIFPanel.mappingFile_changed';
    mappingFile.MatlabArgs={this,'%dialog'};

    mappingSpacer2.Type='text';
    mappingSpacer2.Tag='ReqIFPanel_mappingSpacer2';
    mappingSpacer2.Name=' ';
    mappingSpacer2.RowSpan=[3,3];
    mappingSpacer2.ColSpan=[1,1];

    mappingDescription.Type='text';
    mappingDescription.Tag='ReqIFPanel_mappingInfo';
    mappingDescription.Name=mappingDesc;

    mappingDescription.RowSpan=[3,3];
    mappingDescription.ColSpan=[2,4];

    mappingGroup.Type='group';
    mappingGroup.Name=getString(message('Slvnv:slreq_import:ReqIFAttributeMapping'));
    mappingGroup.LayoutGrid=[3,4];
    mappingGroup.Items={...
    mappingSpacer1,...
    mappingFile,...
    mappingSpacer2,...
    mappingDescription};
    mappingGroup.RowSpan=[2,2];
    mappingGroup.ColSpan=[1,4];

    multiSpecs=this.getMultipleSpecs();
    multiSpecs.RowSpan=[1,1];
    multiSpecs.ColSpan=[1,4];

    items={multiSpecs,mappingGroup};
    grid=[2,1];

end


