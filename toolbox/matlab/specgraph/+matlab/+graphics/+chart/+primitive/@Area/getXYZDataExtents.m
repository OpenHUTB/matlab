function extents=getXYZDataExtents(hObj,transform,constraints)






    hObj.updateLayout();




    xd=hObj.AreaLayoutData.XData';
    yd=hObj.AreaLayoutData.YData(:,2)';
    order=hObj.AreaLayoutData.Order;





    yd(~isfinite(order))=NaN;



    if~isequal(transform,eye(4))

        vertices=[xd;yd;zeros(1,numel(xd));ones(1,numel(xd))];
        finite=all(isfinite(vertices),1);
        vertices=vertices(:,finite);


        vertices=transform*vertices;
        xd=vertices(1,:);
        yd=vertices(2,:);
        zd=vertices(3,:);
    else
        zd=zeros(size(xd));
    end


    if~isempty(xd)&&isfield(constraints,'XConstraints')
        mask=(xd>=constraints.XConstraints(1))&(xd<=constraints.XConstraints(2));
        xd=xd(mask);
        yd=yd(mask);
        zd=zd(mask);
    end


    if~isempty(yd)&&isfield(constraints,'YConstraints')
        mask=(yd>=constraints.YConstraints(1))&(yd<=constraints.YConstraints(2));
        xd=xd(mask);
        yd=yd(mask);
        zd=zd(mask);
    end


    if strcmp(hObj.XLimInclude,'off')
        xd=[];
    end


    if strcmp(hObj.YLimInclude,'off')
        yd=[];
    end


    if strcmp(hObj.ZLimInclude,'off')
        zd=[];
    end


    xlim=matlab.graphics.chart.primitive.utilities.arraytolimits(xd);
    ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(yd);
    zlim=matlab.graphics.chart.primitive.utilities.arraytolimits(zd);


    extents=[xlim;ylim;zlim];
