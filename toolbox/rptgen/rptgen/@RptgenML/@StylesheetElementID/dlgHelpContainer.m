function dlgStruct=dlgHelpContainer(this,varargin)



























    dlgStruct=this.dlgContainer({
    this.dlgText(char(this.DescriptionLong),...
    'WordWrap',true,...
    'RowSpan',[1,1],...
    'ColSpan',[1,1])
    },getString(message('rptgen:RptgenML_StylesheetElementID:helpLabel')),...
    'LayoutGrid',[2,1],'RowStretch',[0,1],...
    varargin{:});
