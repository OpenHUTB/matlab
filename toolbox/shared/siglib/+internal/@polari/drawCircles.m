function drawCircles(p,isRotating)









    ax=p.hAxes;
    hh=p.hCircles;
    normRadii=p.pMagnitudeCircleRadii;
    Nr=numel(normRadii);
    TwoPi=2*pi;




    angResDeg=2;












    if isempty(hh{1})||~ishghandle(hh{1})
        hh{1}=patch(...
        'Parent',ax,...
        'HandleVisibility','off',...
        'Tag',sprintf('PolarGrid%d',p.pAxesIndex));


        b=hggetbehavior(hh{1},'DataCursor');
        b.Enable=false;
        b=hggetbehavior(hh{1},'Plotedit');
        b.Enable=false;

        set(hh{1},'uicontextmenu',p.UIContextMenu_Grid);


        th=[0:angResDeg:360,0];
        x=cosd(th);
        y=sind(th);
        set(hh{1},...
        'Visible','on',...
        'XData',x.*normRadii(Nr),...
        'YData',y.*normRadii(Nr),...
        'ZData',zeros(size(th)),...
        'FaceAlpha',1.0,...
        'EdgeColor','none');

        p.hCircles=hh;
    end


    set(hh{1},...
    'FaceColor',p.GridBackgroundColor,...
    'EdgeColor',p.GridForegroundColor);










    if isempty(hh{2})||~ishghandle(hh{2})
        hh{2}=line(...
        'Parent',ax,...
        'HandleVisibility','off',...
        'Tag',sprintf('PolarGrid%d',p.pAxesIndex));


        b=hggetbehavior(hh{2},'DataCursor');
        b.Enable=false;
        b=hggetbehavior(hh{2},'Plotedit');
        b.Enable=false;


        set(hh{2},'uicontextmenu',p.UIContextMenu_Grid);
        p.hCircles=hh;
    end


    if~isRotating
        if Nr>1






            if 0


                th=(0:angResDeg:360)';
                x=cosd(th);
                y=sind(th);
                xl=[bsxfun(@mtimes,x,normRadii);NaN(1,Nr)];
                yl=[bsxfun(@mtimes,y,normRadii);NaN(1,Nr)];
            else








                Nmax=2+360/angResDeg;
                xl=zeros(Nmax*Nr,1);
                yl=xl;
                j=0;
                for i=1:Nr






                    nr_i=normRadii(i);
                    local_angRes=min(10,angResDeg/nr_i);

                    th_i=[(0:local_angRes:360).';0];
                    if isempty(th_i)
                        th_i=0;
                    end
                    Nth=numel(th_i);
                    k=j+Nth;
                    xl(j+1:k)=nr_i.*cosd(th_i);
                    yl(j+1:k)=nr_i.*sind(th_i);
                    xl(k+1)=NaN;
                    yl(k+1)=NaN;
                    j=k+1;
                end


                xl=xl(1:j);
                yl=yl(1:j);
            end


            set(hh{2},...
            'XData',xl(:),...
            'YData',yl(:),...
            'ZData',getGridZ(p)*ones(numel(xl),1),...
            'Color',p.GridForegroundColor,...
            'LineWidth',p.GridWidth,...
            'Visible',internal.LogicalToOnOff(p.GridVisible));
        else
            hh{2}.Visible='off';
        end
    end




    if isempty(hh{3})||~ishghandle(hh{3})
        hh{3}=patch(...
        'Parent',ax,...
        'HandleVisibility','off',...
        'FaceAlpha',1,...
        'EdgeColor','none',...
        'Tag',sprintf('PolarClip%d',p.pAxesIndex));


        b=hggetbehavior(hh{3},'DataCursor');
        b.Enable=false;
        b=hggetbehavior(hh{3},'Plotedit');
        b.Enable=false;



        set(hh{3},'uicontextmenu',p.UIContextMenu_Master);
        p.hCircles=hh;
    end








    xl=ax.XLim;
    xMin=-max(abs(xl));
    xMax=-xMin;
    yl=ax.YLim;
    yMin=-max(abs(yl));
    yMax=-yMin;
    yMid=(yMin+yMax)/2;
    ro=normRadii(Nr)*1.005;














    ang=getNormalizedAngle(p,p.pAngleLim);
    ang=ang([2,1]);
    del=internal.polariCommon.angleDiff(ang);
    clipping=p.ClipData;



    thresh=100*eps;
    if abs(del)<=thresh||abs(del)>=TwoPi-thresh





        if clipping
            th=0:2:360;
            xa=cosd(th);
            ya=sind(th);
            xc=[xMax,xa.*ro,xMax,xMax,xMin,xMin,xMax];
            yc=[yMid,ya.*ro,yMid,yMin,yMin,yMax,yMax];
        else

            xc=[];
            yc=[];
        end

    elseif abs(ang(1))>thresh&&...
        abs(ang(2))>thresh&&...
        internal.polariCommon.isBetweenAnglesRad(0,ang(1),ang(2))







        if clipping
            spanAng1=internal.polariCommon.angleDiff(0,ang(1));
            spanAng2=internal.polariCommon.angleDiff(0,ang(2));
            if spanAng1<spanAng2

                Npts=ceil(spanAng1*180/pi/2);
                th=internal.polariCommon.linspaceIncrRad(0,ang(1),Npts);
                xa=cos(th);
                ya=sin(th);
                spanAng2=internal.polariCommon.angleDiff(ang(2),0);
                Npts=ceil(spanAng2*180/pi/2);
                th=internal.polariCommon.linspaceIncrRad(ang(2),0,Npts);
            else

                Npts=ceil(spanAng2*180/pi/2);
                th=internal.polariCommon.linspaceIncrRad(0,ang(2),Npts);
                xa=cos(th);
                ya=sin(th);
                spanAng1=internal.polariCommon.angleDiff(ang(1),0);
                Npts=ceil(spanAng1*180/pi/2);
                th=internal.polariCommon.linspaceIncrRad(ang(1),0,Npts);
            end
            xb=cos(th);
            yb=sin(th);
            xc=[xMax,xa.*ro,0,xb.*ro,xMax,xMax,xMin,xMin,xMax];
            yc=[yMid,ya.*ro,yMid,yb.*ro,yMid,yMin,yMin,yMax,yMax];
        else


            del2=TwoPi-del;
            Npts=ceil(del2*180/pi/2);
            th=internal.polariCommon.linspaceIncrRad(ang(2),ang(1),Npts);
            x=cos(th);
            y=sin(th);
            xc=[x.*ro*10,0];
            yc=[y.*ro*10,yMid];
        end
    else





        if clipping
            Npts=ceil(del*180/pi/2);
            th=internal.polariCommon.linspaceIncrRad(ang(1),ang(2),Npts);
            x=cos(th);
            y=sin(th);
            xc=[xMax,0,x.*ro,0,xMax,xMax,xMin,xMin,xMax];
            yc=[yMid,yMid,y.*ro,yMid,yMid,yMin,yMin,yMax,yMax];
        else


            del2=TwoPi-del;
            Npts=ceil(del2*180/pi/2);
            th=internal.polariCommon.linspaceIncrRad(ang(2),ang(1),Npts);
            x=cos(th);
            y=sin(th);
            xc=[x.*ro*10,0];
            yc=[y.*ro*10,yMid];
        end
    end

    zc=0.292+zeros(size(xc));
    set(hh{3},...
    'XData',xc,...
    'YData',yc,...
    'ZData',zc,...
    'FaceColor',getBackgroundColorOfAxes(p));

