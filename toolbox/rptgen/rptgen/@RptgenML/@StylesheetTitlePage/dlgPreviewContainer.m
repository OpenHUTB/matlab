function dlgStruct=dlgPreviewContainer(this,varargin)




    dlgStruct=this.dlgContainer({
    this.dlgText(this.dlgUpdatePreview,...
    'Tag','XmlPreview',...
    'WordWrap',1);
    },getString(message('rptgen:RptgenML_StylesheetElement:previewLabel')),...
    varargin{:});
    dlgStruct.Visible=false;
