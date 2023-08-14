function[clrbarHdl,axesHdl,hfig]=surfaceplot(obj,data,region,scale,vectorindex,current)





    if strcmpi(region,'metal')
        if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP&&...
            ~obj.SolverStruct.hasDielectric
            P=obj.MesherStruct.Mesh.p;
            t=obj.MesherStruct.Mesh.t(:,1:end/2);
        elseif isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP&&...
            obj.SolverStruct.hasDielectric
            index=find(obj.SolverStruct.RWG.Center(3,:)>=0);
            t=obj.MesherStruct.Mesh.t(:,index);
            P=obj.MesherStruct.Mesh.p;
        else
            P=obj.MesherStruct.Mesh.p;
            t=obj.MesherStruct.Mesh.t;
        end
    else
        t=obj.SolverStruct.strdiel.Faces(:,1:obj.SolverStruct.strdiel.FacesNontrivial);
        P=obj.MesherStruct.Mesh.p;
    end


    if strcmpi(scale,'linear')
        C=data(t(1:3,:));
    elseif strcmpi(scale,'log')
        C=log(data(t(1:3,:)));
    elseif strcmpi(scale,'log10')
        C=log10(data(t(1:3,:)));
    else
        C=feval(scale,data(t(1:3,:)));
    end
    X=reshape(P(1,t(1:3,:)),[3,size(t,2)]);
    Y=reshape(P(2,t(1:3,:)),[3,size(t,2)]);
    Z=reshape(P(3,t(1:3,:)),[3,size(t,2)]);

    if vectorindex==1
        T=size(t,2);
        for k=1:T
            Jr(1:3,1)=current(:,k);
            Ur(k)=Jr(1)/(norm(Jr));
            Vr(k)=Jr(2)/(norm(Jr));
            Wr(k)=Jr(3)/(norm(Jr));
            N=t(1:3,k);
            X1(1:3,k)=[P(1,N)]';
            Y1(1:3,k)=[P(2,N)]';
            Z1(1:3,k)=[P(3,N)]';
            Center=([P(:,N(1))]'+[P(:,N(2))]'+[P(:,N(3))]')/3;
            X2(k)=Center(1);
            Y2(k)=Center(2);
            Z2(k)=Center(3);
        end
    end


    if~isempty(get(groot,'CurrentFigure'))
        clf(gcf);
    end
    if vectorindex==1
        h=patch(X1,Y1,Z1,C(:,1:T),'FaceAlpha','1.0','EdgeColor','none');
        colormap(jet(256));
        set(h,'Edgealpha',0)
        hold on
        quiver3(X2,Y2,Z2,Ur,Vr,Wr,0.15,'k');
        hold off;
    else
        h=patch(X,Y,Z,C,'FaceAlpha','1.0','EdgeColor','none');
        colormap(jet(256));
    end

    axesHdl=ancestor(h,'axes');
    clrbarHdl=colorbar(axesHdl);
    if strcmpi(region,'metal')
        em.MeshGeometry.view_antenna_boundary(obj.MesherStruct.Geometry,'none');
    elseif strcmpi(region,'dielectric')

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
    end

    hfig=ancestor(h,'figure');



    ax=findobj(gcf,'type','axes');
    ax.FontSize=8;

    if iscell(obj.MesherStruct.Geometry)
        BorderVertices=cell2mat(cellfun(@(x)x.BorderVertices,obj.MesherStruct.Geometry','UniformOutput',false));
        X=BorderVertices(:,1);
        Y=BorderVertices(:,2);
        Z=BorderVertices(:,3);
    else
        X=obj.MesherStruct.Geometry.BorderVertices(:,1);
        Y=obj.MesherStruct.Geometry.BorderVertices(:,2);
        Z=obj.MesherStruct.Geometry.BorderVertices(:,3);




        if(isa(obj,'draRectangular')||isa(obj,'draCylindrical'))&&...
            (isinf(obj.GroundPlaneLength)||isinf(obj.GroundPlaneWidth))&&...
            strcmpi(region,'dielectric')
            X=obj.MesherStruct.Geometry.SubstrateVertices(:,1);
            Y=obj.MesherStruct.Geometry.SubstrateVertices(:,2);
            Z=obj.MesherStruct.Geometry.SubstrateVertices(:,3);
        end
    end
    reorient=0;
    if isa(obj,'planeWaveExcitation')
        if isa(obj.Element,'platform')
            fw=[];
            feedloc=[];
        else
            fw=getFeedWidth(obj.Element);
            feedloc=obj.Element.FeedLocation;
        end
    else
        feedloc=obj.FeedLocation;
        fw=getFeedWidth(obj);
    end

    [xs,ys,zs]=sphere(50);


    r=fw;
    marginRatio=10/100;

    if all(Z(:)==0)||all(diff(Z(:))==0)&&strcmpi(region,'metal')&&~isa(obj,'installedAntenna')
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

        if~isempty(feedloc)
            zf=zs*r(1)+feedloc(3);
        else
            zf=[];
        end

        minZ=min([Z(1,:),zf(:)']);
        maxZ=max([Z(1,:),zf(:)']);

        margins=marginRatio*(maxZ-minZ)+10^-5;
        maxZ=maxZ+margins(1);
        axesHdl.ZLim=[minZ,maxZ];

    elseif all(X(:)==0)||all(diff(X(:))==0)&&strcmpi(region,'metal')&&~isa(obj,'installedAntenna')
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


        if~isempty(feedloc)
            xf=xs*r(1)+feedloc(1);
        else
            xf=[];
        end

        minX=min([X(1,:),xf(:)']);
        maxX=max([X(1,:),xf(:)']);

        margins=marginRatio*(maxX-minX)+10^-5;
        minX=minX-margins(1);maxX=maxX+margins(1);
        axesHdl.XLim=[minX,maxX];

    elseif all(Y(:)==0)||all(diff(Y(:))==0)&&strcmpi(region,'metal')&&~isa(obj,'installedAntenna')
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


        if~isempty(feedloc)
            yf=ys*r(1)+feedloc(2);
        else
            yf=[];
        end

        minY=min([Y(1,:),yf(:)']);
        maxY=max([Y(1,:),yf(:)']);

        margins=marginRatio*(maxY-minY)+10^-5;
        minY=minY-margins(1);maxY=maxY+margins(1);
        axesHdl.YLim=[minY,maxY];
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
    if reorient&&~isa(obj,'fractalKoch')
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