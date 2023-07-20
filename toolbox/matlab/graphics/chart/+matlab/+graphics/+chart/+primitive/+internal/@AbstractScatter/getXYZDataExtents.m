function extents=getXYZDataExtents(hObj,transform,constraints)




    [xD,yD,zD]=matlab.graphics.chart.primitive.utilities.preprocessextents(hObj.XDataCache(:),hObj.YDataCache(:),hObj.ZDataCache(:));



    if~isequal(transform,eye(4))
        if zD==0
            vertices=transform*[xD,yD,zeros(size(xD)),ones(size(xD))]';
        else
            vertices=transform*[xD,yD,zD,ones(size(xD))]';
        end
        xD=vertices(1,:);
        yD=vertices(2,:);
        zD=vertices(3,:);
    end

    if strcmp(hObj.XLimInclude,'off')
        xD=[];
    end
    if strcmp(hObj.YLimInclude,'off')
        yD=[];
    end
    if strcmp(hObj.ZLimInclude,'off')
        zD=[];
    end

    if~isempty(constraints)
        inmask=[];
        if isfield(constraints,'XConstraints')&&~isempty(xD)
            xmask=(xD>=constraints.XConstraints(1))&(xD<=constraints.XConstraints(2));
            if numel(inmask)==numel(xmask)
                inmask=inmask&xmask;
            else
                inmask=xmask;
            end
        end
        if isfield(constraints,'YConstraints')&&~isempty(yD)
            ymask=(yD>=constraints.YConstraints(1))&(yD<=constraints.YConstraints(2));
            if numel(inmask)==numel(ymask)
                inmask=inmask&ymask;
            else
                inmask=ymask;
            end
        end

        if(numel(inmask)==numel(xD))
            xD=xD(inmask);
        end
        if(numel(inmask)==numel(yD))
            yD=yD(inmask);
        end
    end

    [xlim,ylim,zlim]=matlab.graphics.chart.primitive.utilities.arraytolimits(xD,yD,zD);


    if~strcmp(hObj.XJitter,'none')
        xlim=padextents(xlim,hObj.XJitterWidth/2,constraints.AllowZeroCrossing(1));
    end
    if~strcmp(hObj.YJitter,'none')
        ylim=padextents(ylim,hObj.YJitterWidth/2,constraints.AllowZeroCrossing(2));
    end
    if~strcmp(hObj.ZJitter,'none')
        zlim=padextents(zlim,hObj.ZJitterWidth/2,constraints.AllowZeroCrossing(3));
    end

    extents=[xlim;ylim;zlim];

end


function lim=padextents(lim,pad,islinear)

    if islinear

        lim(1)=lim(1)-pad;
        lim(4)=lim(4)+pad;

        if lim(1)<0&&isnan(lim(2))

            lim(2)=-eps;
        end

        if lim(1)>0
            lim(3)=lim(1);
        elseif lim(4)>0&&isnan(lim(3))

            lim(3)=eps;
        end
        if lim(4)<0
            lim(2)=lim(4);
        end
    else

        if isnan(lim(3))

            lim(1)=-10.^(log10(-lim(1))+pad);
            lim(2)=-10.^(log10(-lim(2))-pad);
            lim(4)=lim(2);
        else

            lim(3)=10.^(log10(lim(3))-pad);
            lim(4)=10.^(log10(lim(4))+pad);
            if lim(1)>0
                lim(1)=lim(3);
            end
        end
    end

end

