function dlgStruct=getDialogSchema(this,name)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return
    end


    [wMinNumBlocks,lMinNumBlocks]=this.dlgWidget('minNumBlocks',...
    'RowSpan',[1,1],...
    'ColSpan',[2,2]);


    [wMinNumSubSystems,lMinNumSubSystems]=this.dlgWidget('minNumSubSystems',...
    'RowSpan',[2,2],...
    'ColSpan',[2,2]);


    [wIsMask,lIsMask]=this.dlgWidget('isMask',...
    'RowSpan',[3,3],...
    'ColSpan',[2,2]);

    wCustomFilter=this.dlgWidget('customFilterCode',...
    'RowSpan',[4,4],...
    'ColSpan',[1,2],...
    'Type','editarea');

    pProps=this.dlgContainer({
lMinNumBlocks
wMinNumBlocks

lMinNumSubSystems
wMinNumSubSystems

lIsMask
wIsMask

wCustomFilter
    },getString(message('RptgenSL:rsl_csl_sys_filter:conditionsLabel')),...
    'LayoutGrid',[4,2],...
    'ColStretch',[0,1],...
    'RowSpan',[1,1],...
    'ColSpan',[1,1]);


    dlgStruct=this.dlgMain(name,{
pProps
    },...
    'LayoutGrid',[2,1],...
    'RowStretch',[0,1]);
