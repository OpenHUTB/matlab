function dlgStruct=dlgHelpContainer(this,varargin)













    dlgStruct=this.dlgContainer({
    this.dlgText(sprintf(getString(message('rptgen:RptgenML_StylesheetHeaderCell:headerFooterOptionDescription'))),...
    'WordWrap',1)
    },getString(message('rptgen:RptgenML_StylesheetHeaderCell:helpLabel')),...
    varargin{:});


