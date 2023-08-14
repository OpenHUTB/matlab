function axesData=getAxesData(hFig)


    hAxesList=findall(hFig,'Type','axes','HandleVisibility','on');

    axesData={};

    for i=1:numel(hAxesList)
        hAxes=hAxesList(i);


        axData.allowZoom=true;
        axData.allowPan=true;
        axData.allowRotate=true;

        hBehavior=hggetbehavior(hAxes,'Zoom','-peek');
        if~isempty(hBehavior)
            axData.allowZoom=hBehavior.Enable;
        end
        hBehavior=hggetbehavior(hAxes,'Pan','-peek');
        if~isempty(hBehavior)
            axData.allowPan=hBehavior.Enable;
        end
        hBehavior=hggetbehavior(hAxes,'Rotate3d','-peek');
        if~isempty(hBehavior)
            axData.allowRotate=hBehavior.Enable;
        end

        axData.id=mls.internal.handleID('toID',hAxes);


        figParent=ancestor(hAxes,'figure');
        currUnits=get(hAxes,'Units');
        pos=get(hAxes,'Position');
        posRect=hgconvertunits(figParent,pos,currUnits,'normalized',figParent);
        axData.Position=posRect;


        axData.CameraTarget=get(hAxes,'CameraTarget');
        axData.CameraUpVector=get(hAxes,'CameraUpVector');
        axData.CameraViewAngle=get(hAxes,'CameraViewAngle');
        axData.CameraPosition=get(hAxes,'CameraPosition');
        axData.DataAspectRatio=get(hAxes,'DataAspectRatio');
        axData.Projection=get(hAxes,'Projection');
        axData.XLim=ruler2num(get(hAxes,'XLim'),get(hAxes,'XAxis'));





        hYAxes=get(hAxes,'YAxis');



        if numel(hYAxes)>1
            if strcmpi(hAxes.YAxisLocation,'left')
                hYAxes=hYAxes(1);
            else
                hYAxes=hYAxes(2);
            end
        end
        axData.YLim=ruler2num(get(hAxes,'YLim'),hYAxes);

        axData.ZLim=ruler2num(get(hAxes,'ZLim'),get(hAxes,'ZAxis'));


        axData.XLabel=get(get(hAxes,'XLabel'),'String');
        axData.YLabel=get(get(hAxes,'YLabel'),'String');
        axData.ZLabel=get(get(hAxes,'ZLabel'),'String');
        axData.Title=get(get(hAxes,'Title'),'String');

        axData.PlotBoxAspectRatio=get(hAxes,'PlotBoxAspectRatio');
        axData.OuterPosition=get(hAxes,'OuterPosition');


        if is2D(hAxes)
            axData.type='2d';
        else
            axData.type='3d';
        end

        axesData{end+1}=axData;%#ok<AGROW>
    end

end