


function init(obj)

    obj.fClickEventData=[];

    code=simulinkcoder.internal.Report.getInstance;
    obj.fListeners{end+1}=event.listener(code,'Click',@obj.onCodeViewerClick);