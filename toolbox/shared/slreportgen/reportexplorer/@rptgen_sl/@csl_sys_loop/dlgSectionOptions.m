function dlgStruct=dlgSectionOptions(this,varargin)







    if(this.HierarchicalSectionNumbering&&~strcmpi(this.SortBy,'none'))
        this.ErrorMessage=getString(message('RptgenSL:rsl_csl_sys_loop:numberSystemsByHierarchyError'));
    else
        this.ErrorMessage='';
    end


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyChangedEvent',this);

    wObjectSection=this.dlgWidget('ObjectSection',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1],...
    'DialogRefresh',true);

    wShowTypeInTitle=this.dlgWidget('ShowTypeInTitle',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1],...
    'Enabled',this.ObjectSection);

    wHierarchicalSectionNumbering=this.dlgWidget('HierarchicalSectionNumbering',...
    'RowSpan',[3,3],...
    'ColSpan',[1,1],...
    'DialogRefresh',true,...
    'Enabled',this.ObjectSection);

    wObjectAnchor=this.dlgWidget('ObjectAnchor',...
    'RowSpan',[4,4],...
    'ColSpan',[1,1]);

    dlgStruct=this.dlgContainer({
wObjectSection
wShowTypeInTitle
wHierarchicalSectionNumbering
wObjectAnchor
    },getString(message('RptgenSL:rsl_csl_sys_loop:sectionOptionsLabel')),...
    'LayoutGrid',[4,1],...
    varargin{:});



