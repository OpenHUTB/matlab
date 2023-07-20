function UD=rescale_axes_to_fit_data(UD,axesIndex,forceResize,doFast)







    if isempty(UD.axes(axesIndex).channels)
        return;
    end

    if nargin<4
        doFast=0;
    end

    if nargin<3
        forceResize=0;
    end

    if~doFast
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end

    channelIdx=UD.axes(axesIndex).channels;
    minYvalues=[];
    maxYvalues=[];

    ActiveGroup=UD.sbobj.ActiveGroup;
    for ch=channelIdx(:)'
        [ymin,ymax]=find_y_range_from_x(UD.sbobj.Groups(ActiveGroup).Signals(ch).XData,...
        UD.sbobj.Groups(ActiveGroup).Signals(ch).YData,...
        UD.common.minTime,...
        UD.common.maxTime);
        minYvalues=[minYvalues,ymin];%#ok<AGROW>
        maxYvalues=[maxYvalues,ymax];%#ok<AGROW>
    end

    minY=min(minYvalues);
    maxY=max(maxYvalues);





    if~forceResize
        yLim=get(UD.axes(axesIndex).handle,'YLim');
        if(yLim(1)<minY&&yLim(2)>maxY)&&(maxY>0.5*yLim(2))
            return;
        end
    end


    if(maxY-minY)<(20*realmin),
        newYlim=round(maxY+[-1,1]);
        if(newYlim(1)==newYlim(2))

            if(newYlim(1)>0)
                newYlim=newYlim.*[0.9,1.1];
            else
                newYlim=newYlim.*[1.1,0.9];
            end
        end
        UD.axes(axesIndex).yLim=newYlim;
        set(UD.axes(axesIndex).handle,'YLim',newYlim);
        if~doFast
            update_axes_label(UD.axes(axesIndex));
        end
        return;
    end



    diff=maxY-minY;
    if maxY*minY>0&&((minY>0&&diff>(2*minY))||(maxY<0&&diff>(-2*maxY)))
        includeZero=1;
    else
        includeZero=0;
    end
    orderOfMagnitude=ceil(log10(diff));

    baseStep=10^(orderOfMagnitude-1);

    if(diff/baseStep)<1.5
        step=baseStep/10;
    elseif(diff/baseStep)<6
        step=baseStep/2;
    else
        step=baseStep;
    end

    if(maxY>0)
        newYlim(2)=step*ceil(1.05*maxY/step);
        if minY==0
            newYlim(1)=-step;
        elseif includeZero
            newYlim(1)=0;
        else
            if minY>0
                newYlim(1)=step*floor(0.95*minY/step);
            else
                newYlim(1)=step*floor(1.05*minY/step);
            end
        end
    else
        if maxY==0
            newYlim(2)=step;
        elseif includeZero
            newYlim(2)=0;
        else
            newYlim(2)=step*ceil(0.95*maxY/step);
        end
        newYlim(1)=step*floor(1.05*minY/step);
    end

    UD.axes(axesIndex).yLim=newYlim;

    if any(isnan(newYlim))


        newYlim=[minY,maxY];
    end
    set(UD.axes(axesIndex).handle,'YLim',newYlim);







    if~doFast
        update_axes_label(UD.axes(axesIndex));
    end
end


function[ymin,ymax]=find_y_range_from_x(X,Y,xmin,xmax)


    xWinthinLims=(X>=xmin&X<=xmax);
    if all(xWinthinLims)
        ymin=min(Y);
        ymax=max(Y);
    else
        Ind=find(xWinthinLims);
        if isempty(Ind)
            y1=scalar_interp(xmin,X,Y);
            y2=scalar_interp(xmax,X,Y);
            ymin=min([y1,y2]);
            ymax=max([y1,y2]);
        else
            if Ind(1)~=1
                I=Ind(1)-1;
                Y(I)=scalar_interp(xmin,X,Y);
                xWinthinLims(I)=true;
            end
            if Ind(end)~=length(X)
                I=Ind(end)+1;
                Y(I)=scalar_interp(xmax,X,Y);
                xWinthinLims(I)=true;

            end
            Y=Y(xWinthinLims);
            ymin=min(Y);
            ymax=max(Y);
        end
    end
end

