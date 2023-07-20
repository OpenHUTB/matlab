function[clrbarHdl,axesHdl,hfig]=volumeplot(obj,data,scale)





    P=obj.MesherStruct.Mesh.p;
    t=obj.MesherStruct.Mesh.T;

    t1=[];
    if length(data)~=max(t,[],"all")


        Tet=t;
        Tetnew=unique(Tet(1:4,:));
        siz1=1:size(Tetnew,1);
        TetMat=Tet;
        TetMat(1:4,:)=0;

        for k=1:size(Tet,1)
            for i=1:size(Tet,2)
                c=Tetnew(:,1)==Tet(k,i);
                TetMat(k,i)=siz1(c);
            end
        end
        t1=t;
        t=TetMat;
    end

    if strcmpi(scale,'linear')
        C=data(t-min(t,[],"all")+1);
    elseif strcmpi(scale,'log')
        C=log(data(t-min(t,[],"all")+1));
    elseif strcmpi(scale,'log10')
        C=log10(data(t-min(t,[],"all")+1));
    else
        C=feval(scale,data(t-min(t,[],"all")+1));
    end
    if~isempty(t1)
        t=t1;
    end
    X=reshape(P(1,t),[4,size(t,2)]);
    Y=reshape(P(2,t),[4,size(t,2)]);
    Z=reshape(P(3,t),[4,size(t,2)]);

    if~isempty(get(groot,'CurrentFigure'))
        clf(gcf);
    end
    h=patch(X,Y,Z,C,'FaceAlpha','0.5','EdgeColor','none');
    colormap(jet(256));

    axesHdl=ancestor(h,'axes');
    clrbarHdl=colorbar(axesHdl);


    if~iscell(obj.MesherStruct.Geometry)
        for i=1:numel(obj.MesherStruct.Geometry.SubstratePolygons)
            if isfield(obj.MesherStruct.Geometry,'SubstrateBoundary')&&...
                ~isempty(obj.MesherStruct.Geometry.SubstrateBoundary)
                patchinfo.Vertices=obj.MesherStruct.Geometry.SubstrateBoundaryVertices;
                patchinfo.Faces=obj.MesherStruct.Geometry.SubstrateBoundary{i};
            else
                patchinfo.Vertices=obj.MesherStruct.Geometry.SubstrateVertices;
                patchinfo.Faces=obj.MesherStruct.Geometry.SubstratePolygons{i};
            end
            patch(patchinfo,'FaceColor','none');
        end
    else
        for m=1:numel(obj.MesherStruct.Geometry)
            if~isempty(obj.MesherStruct.Geometry{m}.SubstrateVertices)
                for i=1:numel(obj.MesherStruct.Geometry{m}.SubstratePolygons)
                    if isfield(obj.MesherStruct.Geometry{m},'SubstrateBoundary')&&...
                        ~isempty(obj.MesherStruct.Geometry{m}.SubstrateBoundary)
                        patchinfo.Vertices=obj.MesherStruct.Geometry{m}.SubstrateBoundaryVertices;
                        patchinfo.Faces=obj.MesherStruct.Geometry{m}.SubstrateBoundary{i};
                    else
                        patchinfo.Vertices=obj.MesherStruct.Geometry{m}.SubstrateVertices;
                        patchinfo.Faces=obj.MesherStruct.Geometry{m}.SubstratePolygons{i};
                    end
                    patch(patchinfo,'FaceColor','none');
                end
            end
        end
    end

    hfig=ancestor(h,'figure');



    ax=findobj(gcf,'type','axes');
    ax.FontSize=8;
    if iscell(obj.MesherStruct.Geometry)
        BorderVertices=cell2mat(cellfun(@(x)x.BorderVertices,...
        obj.MesherStruct.Geometry','UniformOutput',false));
        X=BorderVertices(:,1);
        Y=BorderVertices(:,2);
        Z=BorderVertices(:,3);
    else
        X=obj.MesherStruct.Geometry.BorderVertices(:,1);
        Y=obj.MesherStruct.Geometry.BorderVertices(:,2);
        Z=obj.MesherStruct.Geometry.BorderVertices(:,3);




        if(isa(obj,'draRectangular')||isa(obj,'draCylindrical'))&&...
            (isinf(obj.GroundPlaneLength)||isinf(obj.GroundPlaneWidth))
            X=obj.MesherStruct.Geometry.SubstrateVertices(:,1);
            Y=obj.MesherStruct.Geometry.SubstrateVertices(:,2);
            Z=obj.MesherStruct.Geometry.SubstrateVertices(:,3);
        end
    end
    reorient=0;
    if all(Z(:)==0)||all(diff(Z(:)==0))
        view(axesHdl,2);
        set(ax,'ZTick',[],'ZTickLabel',[]);
        maxval=max([ax.XLim,ax.YLim]);
        minval=min([ax.XLim,ax.YLim]);
        xval=[minval,maxval]./ax.XLim;
        yval=[minval,maxval]./ax.YLim;
        if any(xval>10)
            set(ax,'XTick',[],'XTickLabel',[]);
            reorient=1;
        end
        if any(yval>10)
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
            set(ax,'YTick',[],'YTickLabel',[]);
            reorient=1;
        end
        if any(zval>10)
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
            set(ax,'XTick',[],'XTickLabel',[]);
            reorient=1;
        end
        if any(zval>10)
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
            set(ax,'XTick',[],'XTickLabel',[]);
            reorient=1;
        end
        if any(yval>10)
            set(ax,'YTick',[],'YTickLabel',[]);
            reorient=1;
        end
        if any(zval>10)
            set(ax,'ZTick',[],'ZTickLabel',[]);
            reorient=1;
        end
        view(axesHdl,3);
    end
    daspect([1,1,1]);
    xlabel('x (m)');
    ylabel('y (m)');
    zlabel('z (m)');
    if reorient
        view(axesHdl,-38,30);
    end
    box on;
    z=zoom;
    z.setAxes3DPanAndZoomStyle(ax,'camera');
    plotStruct=getappdata(hfig,'PlotCustomiZationStructure');
    if~isempty(plotStruct)
        tf=plotStruct.BringPlotFigureForward;
    else
        tf=true;
    end
    if tf
        shg;
    end

end
