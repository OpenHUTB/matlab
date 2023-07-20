function A=celltext(theFrame,varargin)






    if nargin==0
        A.Class='celltext';
        A.HorizontalAlignment=[];
        A.VerticalAlignment=[];
        A.FontUnits=[];
        A.FontSize=[];
        A.CellPadding=[];
        A=class(A,'celltext',axistext);
        return
    end

    pos=get(theFrame,'Position');



    x=pos(1)+pos(3)/2;
    y=pos(2)+pos(4)/2;

    if nargin==1
        t=text(x,y,'','Visible','off');
    else
        t=text(x,y,varargin{:},'Visible','off');
    end
    set(t,...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle',...
    'Editing','on',...
    'Clipping','on',...
    'ButtonDownFcn','doclick(gcbo)');
    set(t,'PickableParts','all')

    A.Class='celltext';
    A.HorizontalAlignment='center';
    A.VerticalAlignment='middle';

    axobj=getobj(get(t,'Parent'));
    if~isempty(axobj)
        zoomScale=get(axobj,'ZoomScale');
    else
        zoomScale=1;
    end

    A.FontUnits=get(t,'FontUnits');
    A.FontSize=get(t,'FontSize');
    set(t,'FontSize',A.FontSize*zoomScale,...
    'Visible','on');

    A.CellPadding=.05;

    axistextObj=axistext(t);
    A=class(A,'celltext',axistextObj);
    Ah=scribehandle(A);
    theFrame.NewItem=scribehandle(A);

    A=Ah.Object;



    uic=getscribecontextmenu(t);

    set(t,'UIContextMenu',uic);
    menus=allchild(uic);
    colorMenu=findall(menus,'Tag','ScribeAxistextObjColorMenu');

    delete([findall(menus,'Tag','ScribeAxistextObjCutMenu'),...
    findall(menus,'Tag','ScribeAxistextObjCopyMenu'),...
    findall(menus,'Tag','ScribeAxistextObjPasteMenu'),...
    findall(menus,'Tag','ScribeAxistextObjClearMenu')]);

    set(colorMenu,'Callback','domethod(getobj(gco),''editcolor'')');

    set(findall(allchild(uic),'Tag','ScribeAxistextObjStringMenu'),...
    'Separator','off');



