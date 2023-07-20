function s=computeHoverLocation(p,ev)



































    if isempty(ev)
        ev=p.pLatestMotionEv;
    else
        p.pLatestMotionEv=ev;
    end
    if~isempty(ev)
        p.hFigure.CurrentPoint=ev.Point;
    end













    targetAxes=p.hAxes;
    pt=targetAxes.CurrentPoint;
    xrel=pt(1,1);
    yrel=pt(1,2);
    xlim=targetAxes.XLim;
    ylim=targetAxes.YLim;



    s.inAxes=...
    xrel>=xlim(1)&&xrel<=xlim(2)&&...
    yrel>=ylim(1)&&yrel<=ylim(2);

    s.radius=0;
    s.angle=0;
    s.any=false;
    s.overAngleTicks=false;
    s.overLegend=false;
    s.overMagnitudeTicks=false;
    s.overMarker=false;
    s.overMarkerID='';
    s.overTitleBottom=false;
    s.overTitleTop=false;
    s.overDataset=false;
    s.overDatasetIndex=0;
    s.overGrid=false;
    s.overAntennaReadout=false;
    s.overLobes=false;
    s.overLobesType='';
    s.overSpan=false;
    s.overSpanReadout=false;
    s.overFigPanel=false;


























    if~isempty(ev)
        hitobj=ev.HitObject;
    else
        hitobj=[];
    end



    if isprop(hitobj,'Tag')

        hitTag=hitobj.Tag;
    else
        hitTag='';
    end



    axesIndex=p.pAxesIndex;





    prop='figpanel:';
    s.overFigPanel=strncmpi(hitTag,prop,numel(prop));
    if~s.overFigPanel
        s.overFigPanel=isa(hitobj,'matlab.graphics.shape.internal.FigurePanel');
    end
    if s.overFigPanel
        s.inAxes=true;
        s.any=true;
        return
    end



    prop='smithplotLegend';




    s.overLegend=strncmpi(hitTag,prop,numel(prop));






    if s.overLegend
        s.any=true;
        return
    end









    prop='smithplotTitle';
    tagStr=sprintf('%sTop%d',prop,axesIndex);
    if strcmpi(hitTag,tagStr)
        s.overTitleTop=true;
        s.any=true;
        return
    end
    tagStr=sprintf('%sBottom%d',prop,axesIndex);
    if strcmpi(hitTag,tagStr)
        s.overTitleBottom=true;
        s.any=true;
        return
    end


    if~s.inAxes
        return
    end




    r=hypot(xrel,yrel);
    s.radius=r;



    s.angle=mod(atan2(yrel,xrel),2*pi);





    tagStr=sprintf('SmithData%d',axesIndex);
    s.overDataset=strcmpi(hitTag,tagStr);
    if s.overDataset
        s.overDatasetIndex=getappdata(hitobj,'smithiDatasetIndex');
        s.any=true;
        return
    end



    s.any=s.overGrid||s.overAngleTicks||s.overMagnitudeTicks;
