function doSetup(hObj)




    hObj.addDependencyConsumed({'ref_frame','resolution'});


    set(hObj.Camera,'XLim',[0,1],'YLim',[0,1]);
    set(hObj.DataSpace,'XLim',[0,1],'YLim',[0,1]);


    setupBoxEdge(hObj);
    set(hObj.BoxFace,'VertexData',single([0,0,1,1;0,1,1,0;0,0,0,0]),...
    'Layer','back',...
    'PickableParts','all');
    set(hObj.SelectionHandle,'VertexData',single([0,0,1,1;0,1,1,0;0,0,0,0]),'Visible','off');



    hObj.SelfListenerList(end+1)=event.listener(hObj,'ObjectBeingDestroyed',@(h,e)hObj.doDelete);


    hObj.Tag_I='legend';
    hObj.Type='legend';
    hObj.Interruptible='off';


    peb=hggetbehavior(hObj,'Plotedit');
    peb.KeepContextMenu=true;
    peb.AllowInteriorMove=true;
    peb.ButtonUpFcn=@(h,ed)h.doMethod('ploteditbup',ed);
    peb.EnableCopy=false;


    pb=hggetbehavior(hObj,'Print');
    pb.PrePrintCallback=@(h,cbname)h.doMethod('printcallback',cbname);
    pb.PostPrintCallback=@(h,cbname)h.doMethod('printcallback',cbname);


    setappdata(hObj,'NonDataObject',[]);


    doMethod(hObj,'createDefaultContextMenu');


    doMethod(hObj,'setButtonDownFcn')
