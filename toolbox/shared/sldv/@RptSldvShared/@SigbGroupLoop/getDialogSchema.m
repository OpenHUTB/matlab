function dlgStruct=getDialogSchema(thisComp,name)





































    wObjectAnchor=thisComp.dlgWidget('ObjectAnchor',...
    'RowSpan',[5,5],'ColSpan',[1,2]);

    wShowTypeInTitle=thisComp.dlgWidget('ShowTypeInTitle',...
    'RowSpan',[6,6],'ColSpan',[1,2]);

    wObjectSection=thisComp.dlgWidget('ObjectSection',...
    'RowSpan',[7,7],'ColSpan',[1,2]);

    wSectionType=thisComp.dlgWidget('SectionType',...
    'RowSpan',[8,8],'ColSpan',[1,2],'Name',getString(message('Sldv:RptSldv:Sigb:getDialogSchema:SectionType')));







































    cMain=thisComp.dlgContainer({
wObjectAnchor
wShowTypeInTitle
wObjectSection
wSectionType
    },getString(message('Sldv:RptSldv:Sigb:getDialogSchema:Properties')),...
    'LayoutGrid',[8,2],...
    'ColStretch',[0,1],...
    'RowStretch',[0,0,0,0,0,0,0,0],...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);
















    cHelp=thisComp.dlgContainer({
    thisComp.dlgText(getDescription(thisComp),...
    'WordWrap',true,...
    'ColSpan',[1,1],'RowSpan',[1,1])
    },getString(message('Sldv:RptSldv:Sigb:getDialogSchema:Help')),...
    'LayoutGrid',[2,1],...
    'ColStretch',[1],...
    'RowStretch',[0,1],...
    'ColSpan',[1,1],...
    'RowSpan',[2,2]);














    if strcmp(thisComp.LoopType,'list')
        wObjectList=thisComp.dlgWidget('ObjectList',...
        'ForegroundColor',[1,1,255]);
    else
        wObjectList=thisComp.dlgText(thisComp.loop_getContextString);
    end

    cLoopOn=thisComp.dlgContainer({
    thisComp.dlgWidget('LoopType',...
    'DialogRefresh',true,...
    'RowSpan',[1,1],...
    'ColSpan',[1,1])
    thisComp.dlgSet(wObjectList,...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])
    },getString(message('Sldv:RptSldv:Sigb:getDialogSchema:ReportOn')),...
    'LayoutGrid',[2,1],...
    'ColStretch',1,...
    'RowStretch',[0,1],...
    'ColSpan',[1,1],...
    'RowSpan',[2,2]);

    dlgStruct=thisComp.dlgMain(name,{
cMain
cLoopOn
    },'LayoutGrid',[2,1],...
    'RowStretch',[0,1],...
    'ColStretch',1);


