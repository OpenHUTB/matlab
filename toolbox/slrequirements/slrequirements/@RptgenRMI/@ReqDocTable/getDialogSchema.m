function dlgStruct=getDialogSchema(this,name)






    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    this.dlgWidget('Source',...
    'RowSpan',[1,1],...
    'ColSpan',[1,2])
    this.dlgWidget('TitleType',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1],...
    'DialogRefresh',true)
    this.dlgWidget('TableTitle',...
    'RowSpan',[2,2],...
    'ColSpan',[2,2],...
    'Enabled',strcmp(this.TitleType,'manual'))
    },getString(message('Slvnv:RptgenRMI:NoReqDoc:getDialogSchema:TableOptions')),...
    'LayoutGrid',[2,2],...
    'ColStretch',[0,1])
    this.dlgContainer({
    this.dlgWidget('includeDate')
    this.dlgWidget('includeCount')
    this.dlgWidget('checkPaths')
    this.dlgText('')
    },getString(message('Slvnv:RptgenRMI:NoReqDoc:getDialogSchema:TableColumns')),getString(message('Slvnv:RptgenRMI:NoReqDoc:getDialogSchema:LayoutGrid')),[4,1],'RowStretch',[0,0,0,1])
    this.dlgContainer({
    this.dlgWidget('useIDs')
    this.dlgWidget('useDOORS')
    this.dlgText('')
    },getString(message('Slvnv:RptgenRMI:NoReqDoc:getDialogSchema:DocumentReferences')),getString(message('Slvnv:RptgenRMI:NoReqDoc:getDialogSchema:LayoutGrid')),[3,1],'RowStretch',[0,0,1])
    });
