function dlgStruct=dlgSectionOptions(this,varargin)







    currRow=1;
    wObjectSection=this.dlgWidget('ObjectSection',...
    'RowSpan',[currRow,currRow],...
    'ColSpan',[1,1],...
    'DialogRefresh',true);
    currRow=currRow+1;

    dlgStruct=this.dlgContainer({
wObjectSection
    },getString(message('rptgen:r_rpt_looper:sectionOptionsLabel')),...
    'LayoutGrid',[currRow,1],...
    varargin{:});

end
