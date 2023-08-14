function allAxes=hitAxes(hFig,evd)




    allAxes=matlab.graphics.GraphicsPlaceholder.empty;

    if matlab.graphics.interaction.internal.hitLegendWithDefaultButtonDownFcn(evd)
        return
    end

    if isprop(evd,'Point')||isfield(evd,'Point')
        pt=evd.Point;
    else
        pt=get(hFig,'CurrentPoint');
    end




    if isprop(evd,'HitObject')&&~isempty(evd.HitObject)&&isvalid(evd.HitObject)
        HitObject=evd.HitObject;
        container=ancestor(HitObject,'matlab.ui.internal.mixin.CanvasHostMixin');
        chartcontainer=ancestor(HitObject,'matlab.graphics.chart.internal.ChartBaseProxy');
        layout=ancestor(HitObject,'matlab.graphics.layout.Layout');

        if~isempty(layout)&&isempty(chartcontainer)
            axList=findall(layout,'-depth',1,'Type','axes','HitTest','on');
        elseif~isempty(chartcontainer)
            axList=findobjinternal(chartcontainer,'Type','axes','HitTest','on');
        else
            axList=findall(container,'-depth',1,'Type','axes','HitTest','on');

            layoutList=findobj(container,'-depth',1,'-isa','matlab.graphics.layout.Layout');
            for i=1:numel(layoutList)
                axList=[axList,findall(layoutList,'Type','axes','HitTest','on')];%#ok<AGROW>
            end
        end

        if~isempty(axList)
            offset=calculateOffset(container,axList(1));
            offsets=repmat(offset,numel(axList),1);
        end

        vp=matlab.graphics.interaction.internal.getViewportInDevicePixels(hFig,container);
    else
        axList=findall(hFig,'Type','axes','HitTest','on');
        axList=removeAxesInOffscreenContainers(axList);

        if~isempty(axList)
            offsets=zeros(numel(axList),2);
            for i=1:numel(axList)
                container=ancestor(axList(i),'matlab.ui.internal.mixin.CanvasHostMixin');
                vp=matlab.graphics.interaction.internal.getViewportInDevicePixels(hFig,container);
                offsets(i,:)=calculateOffset(axList(i).Parent,axList(i));
            end
        end
    end

    point=getPointInPixels(hFig,evd,pt);
    for k=1:numel(axList)
        if matlab.graphics.interaction.internal.isAxesHit(axList(k),vp,point,offsets(k,:))
            allAxes(end+1)=axList(k);%#ok<AGROW>
        end
    end






    function offset=calculateOffset(container,ax)
        offset=[0,0];
        if~strcmp(container.Type,'figure')&&~isempty(ax)
            pixelpos=getpixelposition(ax,true);
            pos=getpixelposition(ax,false);
            offset=pixelpos(1:2)-pos(1:2);
        end




        function axFinal=removeAxesInOffscreenContainers(axOrig)



            tab=ancestor(axOrig,'matlab.ui.container.Tab');


            if~isempty(tab)&&~(iscell(tab)&&all(cellfun(@isempty,tab)))
                axRemove=gobjects;
                if isscalar(tab)
                    tab={tab};
                end
                for i=1:numel(axOrig)
                    if~isempty(tab{i})&&(tab{i}~=tab{i}.Parent.SelectedTab)
                        axRemove(end+1)=axOrig(i);%#ok<AGROW>
                    end
                end


                axFinal=setdiff(axOrig,axRemove,'stable');
            else
                axFinal=axOrig;
            end

            function new_pt=getPointInPixels(hFig,~,old_pt)

                if~strcmpi(hFig.Units,'Pixels')
                    ptrect=hgconvertunits(hFig,[old_pt,1,1],hFig.Units,'Pixels',hFig);
                    new_pt=ptrect(1:2);
                else
                    new_pt=old_pt;
                end
