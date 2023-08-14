
function doZoom2d(hAxesVector,currXLim,currYLim,newXLim,newYLim)


    if~iscell(currXLim)
        currXLim={currXLim};
        currYLim={currYLim};
        newXLim={newXLim};
        newYLim={newYLim};
    end

    for i=1:length(hAxesVector)
        hAxes=hAxesVector(i);
        if strcmp(get(hAxes,'DataAspectRatioMode'),'manual')
            olddx=diff(ruler2num(get(hAxes,'XLim'),get(hAxes,'XAxis')));
            olddy=diff(ruler2num(get(hAxes,'YLim'),get(hAxes,'YAxis')));
            ratio=olddx/olddy;
            dx=newXLim{i}(2)-newXLim{i}(1);
            dy=newYLim{i}(2)-newYLim{i}(1);


            hFig=ancestor(hAxes,'Figure');



            ndx=dx/olddx;
            ndy=dy/olddy;
            pixPosRect=hgconvertunits(hFig,get(hAxes,'Position'),get(hAxes,'Units'),'Pixels',hFig);
            pdx=pixPosRect(1)+pixPosRect(3)*ndx;
            pdy=pixPosRect(2)+pixPosRect(4)*ndy;


            if(pdy>pdx&&~isequal(newYLim,ruler2num(get(hAxes,'YLim'),get(hAxes,'YAxis'))))||...
                isequal(newXLim,ruler2num(get(hAxes,'XLim'),get(hAxes,'XAxis')))
                diffSize=ratio*dy;
                diffDiff=dx-diffSize;
                diffHalf=diffDiff/2;
                newXLim{i}(1)=newXLim{i}(1)+diffHalf;
                newXLim{i}(2)=newXLim{i}(2)-diffHalf;
            else
                diffSize=dx/ratio;
                diffDiff=dy-diffSize;
                diffHalf=diffDiff/2;
                newYLim{i}(1)=newYLim{i}(1)+diffHalf;
                newYLim{i}(2)=newYLim{i}(2)-diffHalf;
            end


            set(hAxes,'CameraViewAngleMode','auto');
        end

        h=findobj(hAxes,'Type','Image');
        if~isempty(h)
            lims=objbounds(hAxes);
            x=lims(1:2);
            y=lims(3:4);


            if x(1)<=currXLim{i}(1)&&x(2)>=currXLim{i}(2)&&...
                y(1)<=currYLim{i}(1)&&y(2)>=currYLim{i}(2)
                dx=newXLim{i}(2)-newXLim{i}(1);
                if newXLim{i}(1)<x(1)
                    newXLim{i}(1)=x(1);
                    newXLim{i}(2)=newXLim{i}(1)+dx;
                end
                if newXLim{i}(2)>x(2)
                    newXLim{i}(2)=x(2);
                    newXLim{i}(1)=newXLim{i}(2)-dx;
                end
                dy=newYLim{i}(2)-newYLim{i}(1);
                if newYLim{i}(1)<y(1)
                    newYLim{i}(1)=y(1);
                    newYLim{i}(2)=newYLim{i}(1)+dy;
                end
                if newYLim{i}(2)>y(2)
                    newYLim{i}(2)=y(2);
                    newYLim{i}(1)=newYLim{i}(2)-dy;
                end


                if newXLim{i}(1)<x(1)
                    newXLim{i}(1)=x(1);
                end
                if newXLim{i}(2)>x(2)
                    newXLim{i}(2)=x(2);
                end
                if newYLim{i}(1)<y(1)
                    newYLim{i}(1)=y(1);
                end
                if newYLim{i}(2)>y(2)
                    newYLim{i}(2)=y(2);
                end
            end
        end


        xlim(hAxes,num2ruler(newXLim{i},get(hAxes,'XAxis')));
        ylim(hAxes,num2ruler(newYLim{i},get(hAxes,'YAxis')));
    end

end