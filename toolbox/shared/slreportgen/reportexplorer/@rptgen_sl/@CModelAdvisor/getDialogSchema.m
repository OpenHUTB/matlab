function dlgStruct=getDialogSchema(thisComp,name)






















    wReuseReport=thisComp.dlgWidget('ReuseReport',...
    'RowSpan',[1,1],'ColSpan',[1,2]);


    cMain=thisComp.dlgContainer({
wReuseReport
    },getString(message('RptgenSL:rsl_CModelAdvisor:propertiesLabel')),...
    'LayoutGrid',[1,2],...
    'ColStretch',[0,1],...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);


    dlgStruct=thisComp.dlgMain(name,{
cMain
    },'LayoutGrid',[2,1],...
    'RowStretch',[0,1]);

