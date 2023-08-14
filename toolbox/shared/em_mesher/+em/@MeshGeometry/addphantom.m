function[X,Y,Z]=addphantom(obj,X,Y,Z)

    if~isprop(obj,'Phantom')
        return;
    end

    if isempty(obj.Phantom)
        return;
    end

    if iscell(obj.MesherStruct.Geometry)
        mul=obj.MesherStruct.Geometry{1}.multiplier;
    else
        mul=obj.MesherStruct.Geometry.multiplier;
    end

    FBtri=obj.MesherStruct.Geometry.SubstratePolygons{1};
    FBpoints=obj.MesherStruct.Geometry.SubstrateVertices.*mul;

    hold on;
    H=trisurf(FBtri,FBpoints(:,1),FBpoints(:,2),FBpoints(:,3),...
    'FaceColor',[0.1,0.7,0.5],'FaceAlpha',0.8,'EdgeColor','k',...
    'LineWidth',0.01);
    hold off;

    val=get(H,'Annotation');
    set(get(val,'LegendInformation'),'IconDisplayStyle','on');
    set(H,'DisplayName','dielectric');

    hax=gca;
    val=0;
    if max(X)<max(FBpoints(:,1))
        hax.XLim=[min(FBpoints(:,1)),max(FBpoints(:,1))];
        val=1;
    end

    if max(Y)<max(FBpoints(:,2))
        hax.YLim=[min(FBpoints(:,2)),max(FBpoints(:,2))];
        val=1;
    end

    if max(Z)<max(FBpoints(:,3))
        hax.ZLim=[min(FBpoints(:,3)),max(FBpoints(:,3))];
        val=1;
    end

    if val
        X=[X;FBpoints(:,1)];
        Y=[Y;FBpoints(:,2)];
        Z=[Z;FBpoints(:,3)];
    end

end