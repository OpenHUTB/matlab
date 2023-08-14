function doSetup(hObj)




    hObj.addDependencyConsumed({'ref_frame','resolution'});


    set(hObj.Camera,'XLim',[0,1],'YLim',[0,1]);
    set(hObj.DataSpace,'XLim',[0,1],'YLim',[0,1]);


    setupBoxEdge(hObj);
    set(hObj.BoxFace,'VertexData',single([0,0,1,1;0,1,1,0;0,0,0,0]),...
    'Layer','back',...
    'PickableParts','all');
    set(hObj.SelectionHandle,'VertexData',single([0,0,1,1;0,1,1,0;0,0,0,0]),'Visible','off');