
function I=calc_channel_points(XData,YData,Pfig,axesH)






    Xfigcoord=conv_x_to_fig_coord(XData,axesH);
    Yfigcoord=conv_y_to_fig_coord(YData,axesH);

    [th,r]=cart2pol(Xfigcoord-Pfig(1),Yfigcoord-Pfig(2));
    minDist=min(r);


    geomMeanX=r(1:(end-1)).*r(2:end)./(r(1:(end-1))+r(2:end));


    colinear=abs(mod(th(1:(end-1))-th(2:end),2*pi)-pi);


    d=colinear.*geomMeanX;
    closestSegment=find(d==min(d));
    closestSegment=closestSegment(1)+[0,1];


    closestIndx=find(r==minDist);
    closestIndx=closestIndx(1);

    if(minDist>4)
        I=closestSegment;
    else
        I=closestIndx;
    end
end

function xFig=conv_x_to_fig_coord(xAx,axesH)


    axPos=get(axesH,'Position');
    xLim=get(axesH,'XLim');
    conv=axPos(3)/diff(xLim);
    xFig=(xAx-xLim(1))*conv+axPos(1);
end
function yFig=conv_y_to_fig_coord(yAx,axesH)


    axPos=get(axesH,'Position');
    yLim=get(axesH,'YLim');
    conv=axPos(4)/diff(yLim);
    yFig=(yAx-yLim(1))*conv+axPos(2);
end
