function doSetup(hObj)







    set(hObj.Camera,'XLim',[0,1],'YLim',[0,1]);
    ds=hObj.DataSpace;
    ds.AllowOptimizedTransform='off';
    set(ds,'XLim',[0,1],'YLim',[0,1]);


    set(hObj.Face,'VertexData',single([0,0,0;1,0,0;1,1,0;0,1,0]'));
    set(hObj.Face,'ColorData',single([0,0,1,1]),'ColorBinding','interpolated','ColorType','colormapped');






    setUnitsAndPosition(hObj.Title,'points',[0,0,0]);


    set(hObj.Title,'UnitsMode','auto','PositionMode','auto');

    set(hObj.Title,'HorizontalAlignment','center','VerticalAlignment','bottom');


    set(hObj.SelectionHandle,'VertexData',single([0,0,1,1;0,1,1,0;0,0,0,0]));


    r=hObj.Ruler;
    set(r,'Axis',1,'FirstCrossoverAxis',0,'FirstCrossoverValue',inf,'SecondCrossoverValue',-inf,'AxesLayer','top');


    addlistener(hObj,'FontSize','PostSet',@(h,e)eval('e.AffectedObject.Label_I.FontSizeMode=''auto'';'));


    r.LabelFontSizeMultiplier=1;



    hObj.SelfListenerList(end+1)=addlistener(hObj,'ObjectBeingDestroyed',@(h,e)hObj.doDelete);


    set(hObj.Face,'Texture',matlab.graphics.primitive.world.Texture);
    hObj.Type='colorbar';
    hObj.Tag_I='Colorbar';
    hObj.Interruptible='off';



    hObj.Ruler.Label_I=matlab.graphics.primitive.Text;


    setappdata(hObj,'NonDataObject',[]);


    b=hggetbehavior(hObj,'Plotedit');
    b.MouseOverFcn=@(es,ed)hObj.doMethod('mouseover',ed);
    b.ButtonDownFcn=@(es,ed)hObj.doMethod('bdown');
    b.KeepContextMenu=true;
    b.AllowInteriorMove=true;
    b.EnableCopy=false;



    doMethod(hObj,'createDefaultContextMenu');



    hObj.BoxHandle.EdgeStyle='full';
