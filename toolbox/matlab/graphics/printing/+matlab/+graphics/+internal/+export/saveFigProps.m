function pj=saveFigProps(pj)




    parentFig=ancestor(pj.Handles{1},'figure');
    pj.temp.oldHandles=pj.Handles;

    pj.temp.ObjUnitsModified=[];
    pj.temp.PaintDisabled=false;
    pj.temp.oldProps.HandleVisibility=get(parentFig,'HandleVisibility');
    pj.temp.oldProps.Units=get(parentFig,'Units');
    pj.temp.oldProps.Visible=get(parentFig,'Visible');
    pj.temp.oldProps.VisibleMode=get(parentFig,'VisibleMode');
    if~matlab.ui.internal.isUIFigure(parentFig)
        pj.temp.oldProps.WindowStyle=get(parentFig,'WindowStyle');
    end


    if~matlab.ui.internal.isUIFigure(parentFig)&&...
        ~strcmp(pj.temp.oldProps.WindowStyle,'docked')

        pj.temp.oldProps.WindowState=get(parentFig,'WindowState');
    end

    if~matlab.ui.internal.isUIFigure(parentFig)

        pj.temp.oldProps.Renderer_I=get(parentFig,'Renderer_I');
    end
    pj.temp.oldProps.ResizeFcn=get(parentFig,'ResizeFcn');

    pj.temp.oldProps.InPrint=get(parentFig,'InPrint');


    pj.temp.oldProps.Position=get(parentFig,'Position');
    if~matlab.ui.internal.isUIFigure(parentFig)






        pj.temp.oldProps.PaperPosition=get(parentFig,'PaperPosition');
        pj.temp.oldProps.PaperPositionMode=get(parentFig,'PaperPositionMode');
    end

    if~isempty(get(groot,'CurrentFigure'))
        pj.temp.CurrentFigure=get(groot,'CurrentFigure');
    end
end
