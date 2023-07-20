function dlgStruct=loop_getDialogSchema(this,~)





    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage('panel',true);
        return;
    end


    rowNum=1;
    wLoopType=this.dlgWidget('LoopType',...
    'DialogRefresh',true,...
    'RowSpan',[rowNum,rowNum],...
    'ColSpan',[1,1]);

    rowNum=rowNum+1;

    if strcmp(this.LoopType,'list')
        wDictionariesList=this.dlgWidgetStringVector('DictionariesList');
        wDictionariesList.ForegroundColor=[1,1,255];
        wDictionariesList.ToolTip=msg(this,'WdgtLoopTypeListToolTip');
        layoutGrid=[2,1];
        reportOnRowStretch=[0,1];
    else
        wDictionariesList=this.dlgText(this.loop_getContextString());
        layoutGrid=[3,1];
        reportOnRowStretch=[0,0,1];
    end

    wDictionariesSet=this.dlgSet(wDictionariesList,...
    'RowSpan',[rowNum,rowNum],...
    'ColSpan',[1,1]);

    pReportOn=this.dlgContainer({
wLoopType
wDictionariesSet
    }...
    ,this.msg('WdgtLblReportOn'),...
    'LayoutGrid',layoutGrid,...
    'RowStretch',reportOnRowStretch...
    );

    dlgStruct={
pReportOn
    };
end


