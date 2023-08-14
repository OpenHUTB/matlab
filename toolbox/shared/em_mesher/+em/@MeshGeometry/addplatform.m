function[X,Y,Z]=addplatform(obj,X,Y,Z,mul)

    if~isprop(obj,'Platform')
        return;
    end

    createGeometry(obj.Platform);
    geom=getGeometry(obj.Platform);
    FBpoints=geom.BorderVertices;
    FBpoints=orientGeom(obj,FBpoints.').';
    FBpoints=FBpoints*mul;
    FBtri=geom.polygons{1};
    hold on;
    H=trisurf(FBtri,FBpoints(:,1),FBpoints(:,2),FBpoints(:,3),...
    'FaceColor',[0.5,0.5,0.5],'FaceAlpha',0.8,'EdgeColor',...
    [0.49,0.49,0.49],'EdgeAlpha',0.1);
    hold off;

    val=get(H,'Annotation');
    set(get(val,'LegendInformation'),'IconDisplayStyle','on');
    set(H,'DisplayName','platform');

    if isscalar(obj.MesherStruct.Geometry)
        elemdim=obj.MesherStruct.Geometry.MaxFeatureSize*mul;
    else
        for m=1:numel(obj.MesherStruct.Geometry)
            maxfeature(m)=obj.MesherStruct.Geometry{m}.MaxFeatureSize*mul;
        end
        elemdim=min(maxfeature);
    end

    for m=1:numel(obj.ElementPosition)/3
        aa=sprintf('Element%d',m);
        text(obj.ElementPosition(m,1)*mul,obj.ElementPosition(m,2)*mul,...
        obj.ElementPosition(m,3)*mul,aa,'Color','k');
    end

    X=[X;FBpoints(:,1)];
    Y=[Y;FBpoints(:,2)];
    Z=[Z;FBpoints(:,3)];

    hax=gca;
    if(min(X)~=max(X))
        hax.XLim=[min(X),max(X)];
    end
    if(min(Y)~=max(Y))
        hax.YLim=[min(Y),max(Y)];
    end
    if(min(Z)~=max(Z))
        hax.ZLim=[min(Z),max(Z)];
    end
end