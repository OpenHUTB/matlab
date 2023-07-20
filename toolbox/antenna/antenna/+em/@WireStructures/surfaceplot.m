function[clrbarHdl,axesHdl,hfig]=surfaceplot(obj,data,scale)






    if strcmpi(scale,'linear')
        C=data;
    elseif strcmpi(scale,'log')
        C=log(data);
    elseif strcmpi(scale,'log10')
        C=log10(data);
    else
        C=feval(scale,data);
    end

    if~isempty(get(groot,'CurrentFigure'))
        clf(gcf);
    end

    defColors=obj.MesherStruct.Mesh.volDataBoth.Colors;
    obj.MesherStruct.Mesh.volDataBoth.Colors=C;
    p=obj.MesherStruct.Mesh.wiresBoth.show_internal(3,...
    obj.MesherStruct.Mesh.volDataBoth,false);
    obj.MesherStruct.Mesh.volDataBoth.Colors=defColors;


    marginRatio=10/100;
    b=obj.MesherStruct.Geometry.volData.Bounds.';
    minX=min(b(1,:));
    minY=min(b(2,:));
    minZ=min(b(3,:));
    maxX=max(b(1,:));
    maxY=max(b(2,:));
    maxZ=max(b(3,:));
    minAll=min([minX,minY,minZ]);
    maxAll=max([maxX,maxY,maxZ]);
    minMargin=(maxAll-minAll)/10;
    margins=marginRatio*[max(maxX-minX,minMargin),...
    max(maxY-minY,minMargin),max(maxZ-minZ,minMargin)]+10^-5;
    axis([minX-margins(1),maxX+margins(1)...
    ,minY-margins(2),maxY+margins(2),minZ,maxZ+margins(3)]);

    h=p(1);
    colormap(jet(256));
    axesHdl=ancestor(h,'axes');
    clrbarHdl=colorbar(axesHdl);

    hfig=ancestor(h,'figure');
    radiiScaleText=sprintf('wire radii scale: 1:%d',...
    obj.MesherStruct.Geometry.wireRadMultiplier);
    h1=uicontrol('Parent',hfig,'Style','text','Units','Normalized',...
    'Position',[0.72,0.018,0.25,0.05],'String',radiiScaleText,...
    'FontSize',clrbarHdl.FontSize,'HorizontalAlignment','right',...
    'Tag','radiiScaleText');
    set(h1,'BackgroundColor',[0.94,0.94,0.94]);
    set(hfig,'InvertHardCopy','off');
    hfig.SizeChangedFcn=@sbar;




    ax=findobj(gcf,'type','axes');
    ax.FontSize=8;
    BorderVertices=cell2mat(cellfun(@(x)x.Vertices,...
    obj.MesherStruct.Geometry.volData.Surfaces,'UniformOutput',false).');
    X=BorderVertices(:,1);
    Y=BorderVertices(:,2);
    Z=BorderVertices(:,3);
    reorient=0;
    if all(Z(:)==0)||all(diff(Z(:)==0))
        view(axesHdl,2);
        set(ax,'ZTick',[],'ZTickLabel',[]);
        maxval=max([ax.XLim,ax.YLim]);
        minval=min([ax.XLim,ax.YLim]);
        xval=[minval,maxval]./ax.XLim;
        yval=[minval,maxval]./ax.YLim;
        if any(xval>10)
            xx=[min(ax.XTick),max(ax.XTick)];

            set(ax,'XTick',[],'XTickLabel',[]);
            reorient=1;
        end
        if any(yval>10)
            yy=[min(ax.YTick),max(ax.YTick)];

            set(ax,'YTick',[],'YTickLabel',[]);
            reorient=1;
        end
    elseif all(X(:)==0)||all(diff(X(:)==0))
        view(axesHdl,90,0)
        set(ax,'XTick',[],'XTickLabel',[]);
        maxval=max([ax.YLim,ax.ZLim]);
        minval=min([ax.YLim,ax.ZLim]);
        yval=[minval,maxval]./ax.YLim;
        zval=[minval,maxval]./ax.ZLim;
        if any(yval>10)
            yy=[min(ax.YTick),max(ax.YTick)];

            set(ax,'YTick',[],'YTickLabel',[]);
            reorient=1;
        end
        if any(zval>10)
            zz=[min(ax.ZTick),max(ax.ZTick)];

            set(ax,'ZTick',[],'ZTickLabel',[]);
            reorient=1;
        end
    elseif all(Y(:)==0)||all(diff(Y(:)==0))
        view(axesHdl,0,0)
        set(ax,'YTick',[],'YTickLabel',[]);
        maxval=max([ax.XLim,ax.ZLim]);
        minval=min([ax.XLim,ax.ZLim]);
        xval=[minval,maxval]./ax.XLim;
        zval=[minval,maxval]./ax.ZLim;
        if any(xval>10)
            xx=[min(ax.XTick),max(ax.XTick)];

            set(ax,'XTick',[],'XTickLabel',[]);
            reorient=1;
        end
        if any(zval>10)
            zz=[min(ax.ZTick),max(ax.ZTick)];

            set(ax,'ZTick',[],'ZTickLabel',[]);
            reorient=1;
        end
    else
        maxval=max([ax.XLim,ax.YLim,ax.ZLim]);
        minval=min([ax.XLim,ax.YLim,ax.ZLim]);
        xval=[minval,maxval]./ax.XLim;
        yval=[minval,maxval]./ax.YLim;
        zval=[minval,maxval]./ax.ZLim;
        if any(xval>10)
            xx=[min(ax.XTick),max(ax.XTick)];

            set(ax,'XTick',[],'XTickLabel',[]);
            reorient=1;
        end
        if any(yval>10)
            yy=[min(ax.YTick),max(ax.YTick)];

            set(ax,'YTick',[],'YTickLabel',[]);
            reorient=1;
        end
        if any(zval>10)
            zz=[min(ax.ZTick),max(ax.ZTick)];

            set(ax,'ZTick',[],'ZTickLabel',[]);
            reorient=1;
        end
        view(axesHdl,3);
    end
    daspect([1,1,1]);
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');
    if reorient&&~isa(obj.Source,'fractalKoch')
        view(axesHdl,-38,30);
    end
    box on;
    z=zoom;
    z.setAxes3DPanAndZoomStyle(ax,'camera');
    if isFigureBroughtForward(obj,hfig)
        shg;
    end






























end

function sbar(src,callbackdata)%#ok<INUSD>          

    u1=findobj(gcbo,'Tag','radiiScaleText');
    if isempty(u1)
        return;
    end
    u1.Units='pixels';
    u1Pos=u1.Position;
    u1.Units='normalized';
    if u1Pos(3)>150&&u1Pos(4)>15
        u1.Visible='on';
    else
        u1.Visible='off';
    end
end