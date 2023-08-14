function draw_feed(radius,feed_location,p,cmax,hfeed,feedColor,tagval)

    if nargin==4
        hfeed=[];
        feedColor=[176,0,27]/255;
        tagval='feed';
    elseif nargin==5
        feedColor=[176,0,27]/255;
        tagval='feed';
    end

    if isempty(radius)
        radius=0.1e-3;
    end

    if isempty(feed_location)
        feed_location=[0,0,0];
    end

    for i=1:numel(radius)

        r=radius(i)/4;
        [xf,yf,zf]=makeFeedSphere(r,feed_location(i,:));

        hsurf=surface(xf,yf,zf,'FaceColor',feedColor,'EdgeColor',feedColor,...
        'FaceAlpha',0.9,'AmbientStrength',1,'tag',tagval);
        daspect([1,1,1]);

        if~isempty(hfeed)
            set(hsurf,'Parent',hfeed);
        end









    end
    resize_axis(p,radius,feed_location,cmax);
end

function resize_axis(p,r,feedloc,cmax)

    [m,idx]=max(r);
    [xf,yf,zf]=makeFeedSphere(m,feedloc(idx,:));

    marginRatio=10/100;
    minX=min([p(1,:),xf(:)']);
    minY=min([p(2,:),yf(:)']);
    minZ=min([p(3,:),zf(:)']);
    maxX=max([p(1,:),xf(:)']);
    maxY=max([p(2,:),yf(:)']);
    maxZ=max([p(3,:),zf(:)']);
    margins=marginRatio*[maxX-minX,maxY-minY,maxZ-minZ]+10^-5;
    axis([minX-margins(1),maxX+margins(1)...
    ,minY-margins(2),maxY+margins(2),minZ,maxZ+margins(3),cmax]);



end

function[xf,yf,zf]=makeFeedSphere(r,feedloc)
    [xs,ys,zs]=sphere(50);
    if~isscalar(r)
        xf=xs*r(1)+feedloc(1);
        yf=ys*r(1)+feedloc(2);
        zf=zs*r(1)+feedloc(3);
    else
        xf=xs*r+feedloc(1);
        yf=ys*r+feedloc(2);
        zf=zs*r+feedloc(3);
    end
end