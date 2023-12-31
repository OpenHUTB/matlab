function editSchema=getEditSchema(this)




    editBtn=struct(...
    'Type','pushbutton',...
    'Name',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:editButtonLabel')),...
    'Enabled',~isBuiltInTemplate(this),...
    'ObjectMethod','openEditor',...
    'RowSpan',[1,1],...
    'ToolTip',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:editButtonToolTip')),...
    'ColSpan',[1,1]...
    );

    editStyleSheetBtn=struct(...
    'Type','pushbutton',...
    'Name',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:editStyleSheetButtonLabel')),...
    'Enabled',~isBuiltInTemplate(this),...
    'ObjectMethod','openStyleSheet',...
    'RowSpan',[1,1],...
    'ToolTip',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:editStyleSheetButtonToolTip')),...
    'ColSpan',[2,2]...
    );

    wCopyBtn=struct(...
    'Type','pushbutton',...
    'Name',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:copyTemplateButtonLabel')),...
    'ToolTip',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:copyTemplateButtonToolTip')),...
    'ObjectMethod','copyTemplate',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1]...
    );


    wMoveBtn=struct(...
    'Type','pushbutton',...
    'Name',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:moveTemplateButtonLabel')),...
    'ToolTip',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:moveTemplateButtonToolTip')),...
    'Enabled',~isBuiltInTemplate(this),...
    'ObjectMethod','moveTemplate',...
    'RowSpan',[2,2],...
    'ColSpan',[2,2]...
    );


    wDeleteBtn=struct(...
    'Type','pushbutton',...
    'Name',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:deleteTemplateButtonLabel')),...
    'ToolTip',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:deleteTemplateButtonToolTip')),...
    'Enabled',~isBuiltInTemplate(this),...
    'ObjectMethod','deleteTemplate',...
    'RowSpan',[3,3],...
    'ColSpan',[1,1]...
    );

    editSchema=this.dlgContainer({
editBtn
editStyleSheetBtn
wCopyBtn
wMoveBtn
wDeleteBtn
    },getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:editOperationsLabel')),...
    'LayoutGrid',[5,4],...
    'ColStretch',[0,0,0,1]);

