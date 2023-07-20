function dlgStruct=getDialogSchema(this,name)








    wTableTitle=this.dlgWidget('Title',...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);


    wIsBorder=this.dlgWidget('isBorder',...
    'ColSpan',[1,1],...
    'RowSpan',[2,2]);

    wFormattingOptions=this.dlgContainer({
wTableTitle
wIsBorder
    },getString(message('RptgenSL:rsl_CSampleTime:tableOptionsLabel')),...
    'LayoutGrid',[2,2],...
    'RowSpan',[2,2],...
    'ColSpan',[1,1]);


    dlgStruct=this.dlgMain(name,{
wFormattingOptions
    },...
    'LayoutGrid',[3,1],...
    'RowStretch',[0,0,1]);

