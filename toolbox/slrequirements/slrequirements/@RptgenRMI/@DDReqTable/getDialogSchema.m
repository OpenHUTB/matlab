function dlgStruct=getDialogSchema(this,name)






    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    this.dlgWidget('TitleType',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1],...
    'DialogRefresh',true)
    this.dlgWidget('TableTitle',...
    'RowSpan',[2,2],...
    'ColSpan',[2,2],...
    'Enabled',strcmp(this.TitleType,'manual'))
    },getString(message('Slvnv:RptgenRMI:ReqTable:getDialogSchema:xlate_TableOptions')),...
    'LayoutGrid',[2,2],...
    'ColStretch',[0,1])
    this.dlgContainer({
    this.dlgWidget('isDescription')
    this.dlgWidget('isDoc')
    this.dlgWidget('isID')
    this.dlgWidget('isKeyword')
    },getString(message('Slvnv:RptgenRMI:ReqTable:getDialogSchema:xlate_TableColumns')))
    });

