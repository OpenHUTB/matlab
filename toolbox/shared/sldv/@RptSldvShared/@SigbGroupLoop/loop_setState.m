function ok=loop_setState(h,currObj,objName)





    if~ishghandle(currObj)
        ok=false;
        return;
    else
        ok=true;
    end


    adh=rptgen_hg.appdata_hg;

    adh.CurrentFigure=currObj;
    adh.CurrentAxes=get(currObj,'CurrentAxes');
    adh.CurrentObject=get(currObj,'CurrentObject');

    set(0,'CurrentFigure',currObj);

    adh.CurrentName=objName;

    adSL=rptgen_sl.appdata_sl;
    adSL.Context='SignalGroup';
    adSL.CurrentSignalGroup=get(currObj,'Tag');


