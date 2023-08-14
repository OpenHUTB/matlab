function handleToolTipMotion(this,src,event,indices)%#ok<INUSL>






    oldSrcUnits=get(src,'Units');
    cleanUp=onCleanup(@()set(src,'Units',oldSrcUnits));
    set(src,'Units','normalized');
    set(this.fig,'HandleVisibility','Callback');

    currentPoint=get(src,'CurrentPoint');
    axesPosition=getTrueAxesPosition();

    if~((currentPoint(1)>axesPosition(1))&&(currentPoint(1)<(axesPosition(3)+axesPosition(1)))&&...
        (currentPoint(2)>axesPosition(2))&&(currentPoint(2)<(axesPosition(4)+axesPosition(2))))
        set(this.toolTip,'Visible','off');
        return
    elseif(length(indices)==1)
        set(this.toolTip,'Visible','off');
        return
    else
        [numRows,numCols]=computeRowsAndColumns(length(indices));

        frameWidth=1/numCols;
        frameHeight=1/numRows;

        relativePosition=(currentPoint-axesPosition(1:2))./axesPosition(3:4);

        rowPos=ceil(relativePosition(1)/frameWidth);
        colPos=(numRows+1)-ceil(relativePosition(2)/frameHeight);

        curIndex=rowPos+numCols*(colPos-1);
        if(curIndex<=length(indices))
            indexToShow=indices(curIndex);
            dispString=sprintf('Frame %d',indexToShow);
            set(this.toolTip,'String',dispString);
            extent=get(this.toolTip,'Extent');
            newPos=[relativePosition,0];
            newPos(1)=newPos(1)+.022;

            if((newPos(1)+extent(3))>rowPos/numCols)
                newPos(1)=newPos(1)-extent(3)-.022;
            end

            if((newPos(2)-extent(4))<(numRows-colPos)/numRows)
                newPos(2)=newPos(2)+extent(4)/2;
            elseif((newPos(2)+extent(4))>(numCols-colPos)/numRows)
                newPos(2)=newPos(2)-extent(4)/2;
            end

            set(this.toolTip,'Position',newPos);
            set(this.toolTip,'Visible','on');
        else
            set(this.toolTip,'Visible','off');
        end
    end

    function normalizedPos=getTrueAxesPosition()

        ax=this.axis;

        xdata=get(this.image,'XData');
        ydata=get(this.image,'YData');

        if(numel(xdata)==1)
            xdata=[xdata(1),xdata(1)];
        end

        if(numel(ydata)==1)
            ydata=[ydata(1),ydata(1)];
        end

        camera=ax.Camera;
        dataspace=ax.DataSpace;

        pm=camera.GetProjectionMatrix();
        vm=camera.GetViewMatrix();

        dsm=dataspace.getMatrix();

        mtx=pm*vm*dsm;






        corner1=[xdata(1),ydata(1),0,1]';
        corner2=[xdata(2),ydata(2),0,1]';


        ndc1=mtx*corner1;
        ndc2=mtx*corner2;


        n1=ndc1*.5+.5;
        n2=ndc2*.5+.5;


        x=n1(1);
        y=n2(2);
        w=n2(1)-n1(1);
        h=n1(2)-n2(2);

        oldAxesUnits=get(ax,'Units');
        set(ax,'Units','normalized');
        axPosition=get(ax,'Position');
        set(ax,'Units',oldAxesUnits);

        axx=axPosition(1);
        axy=axPosition(2);
        axw=axPosition(3);
        axh=axPosition(4);

        normalizedPos=[axx+x*axw,axy+y*axy,w*axw,h*axh];
    end


end

function[axRows,axCols]=computeRowsAndColumns(nFrames)

    axCols=sqrt(nFrames);
    if(axCols<1)

        axCols=1;
    end
    axRows=nFrames/axCols;
    if(ceil(axCols)-axCols)<(ceil(axRows)-axRows),
        axCols=ceil(axCols);
        axRows=ceil(nFrames/axCols);
    else
        axRows=ceil(axRows);
        axCols=ceil(nFrames/axRows);
    end
end

