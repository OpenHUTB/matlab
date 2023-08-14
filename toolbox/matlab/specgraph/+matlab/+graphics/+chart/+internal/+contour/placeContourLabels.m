function[labelPlacement,contoursForDisplay]=placeContourLabels(updateState,...
    contourLines,levels,labels,cutContoursAtLabels,labelSpacing,...
    textList,fontObj)








    levelNeedsLabel=matlab.graphics.chart.internal.contour.labeledLevels(...
    levels,textList);

    axesInfo=collectAxesInfo(updateState);

    if isempty(contourLines)
        labelPlacement=initializeLabelParameters(0);
        contoursForDisplay=matlab.graphics.chart.internal.contour.ContourLine.empty();
    elseif cutContoursAtLabels







        numContourLines=numel(contourLines);
        labelPlacement=initializeLabelParameters;
        contoursForDisplay(numContourLines,1)=matlab.graphics.chart.internal.contour.ContourLine;
        contourIsEmpty=false(size(contoursForDisplay));

        for k=1:numContourLines
            if levelNeedsLabel(k)
                labelWidth=getLabelWidth(updateState,labels(k),fontObj);

                [labelPlacement_k,contoursForDisplay_k]=placeAndCut(contourLines(k),...
                labelSpacing,axesInfo,labels{k},labelWidth);
                labelPlacement=[labelPlacement,labelPlacement_k];%#ok<AGROW>
                if isempty(contoursForDisplay_k)
                    contourIsEmpty=true;
                else
                    contoursForDisplay(k)=mergeParts(contoursForDisplay_k);
                end
            else
                contoursForDisplay(k)=contourLines(k);
            end
        end
        contoursForDisplay(contourIsEmpty)=[];
    else
        labelPlacement=initializeLabelParameters;
        for k=1:numel(contourLines)
            if levelNeedsLabel(k)
                labelWidth=getLabelWidth(updateState,labels(k),fontObj);
                labelPlacement_k=placeOnly(contourLines(k),...
                labelSpacing,axesInfo,labels{k},labelWidth);
                labelPlacement=[labelPlacement,labelPlacement_k];%#ok<AGROW>
            end
        end
        contoursForDisplay=contourLines;
    end
end

function[labelPlacement,contoursForDisplay]=placeAndCut(contourLines,...
    labelSpacing,axesInfo,label,labelWidth)

    singlePartLines=splitParts(contourLines);
    labelPlacement=initializeLabelParameters;
    numParts=numel(singlePartLines);

    contoursForDisplay(numel(singlePartLines),1)=matlab.graphics.chart.internal.contour.ContourLine;
    contourIsEmpty=false(size(contoursForDisplay));
    for k=1:numParts
        contourLine=singlePartLines(k);
        [x,y]=xyzdata(contourLine);
        level=contourLine.Level;

        cut=true;
        [labelParameters_k,cutParameters_k]=placeLabelsForSinglePart(...
        x,y,level,label,labelWidth,labelSpacing,axesInfo,cut);

        contourLineZ=contourLine.VertexData(3,1);
        for j=1:numel(labelParameters_k)
            labelParameters_k(j).Position(3)=contourLineZ;
        end
        labelPlacement=[labelPlacement,labelParameters_k];%#ok<AGROW>

        if~isempty(cutParameters_k)
            n=isnan(cutParameters_k.XData);
            breaks=[find(n),1+numel(n)];
            [cutParameters_k,n,breaks]=wrapLoops(cutParameters_k,n,breaks);
            stripData=uint32([1,breaks-(0:(numel(breaks)-1))]);
            verticesToKeep=find(~n);
            [stripData,verticesToKeep]=filterIsolatedPoints(stripData,verticesToKeep);
            if~isempty(verticesToKeep)
                vertexData=zeros(3,stripData(end)-1);
                vertexData(1,:)=cutParameters_k.XData(verticesToKeep);
                vertexData(2,:)=cutParameters_k.YData(verticesToKeep);
                vertexData(3,:)=contourLineZ;
                contoursForDisplay(k).Level=cutParameters_k.Level;
                contoursForDisplay(k).VertexData=vertexData;
                contoursForDisplay(k).StripData=stripData;
            else
                contourIsEmpty(k)=true;
            end
        end
    end
    contoursForDisplay(contourIsEmpty)=[];
end

function labelPlacement=placeOnly(contourLines,...
    labelSpacing,axesInfo,label,labelWidth)

    labelPlacement=initializeLabelParameters;
    singlePartLines=splitParts(contourLines);
    numParts=numel(singlePartLines);
    for k=1:numParts
        contourLine=singlePartLines(k);
        [x,y]=xyzdata(contourLine);
        level=contourLine.Level;
        cut=false;
        labelPlacement_k=placeLabelsForSinglePart(...
        x,y,level,label,labelWidth,labelSpacing,axesInfo,cut);
        labelPlacement=[labelPlacement,labelPlacement_k];%#ok<AGROW>
    end
end

function[stripData,verticesToKeep]=filterIsolatedPoints(stripData,verticesToKeep)

    isolated=[(diff(stripData)==1),false];

    if any(isolated)

        verticesToKeep(stripData(isolated))=[];




        stripData=stripData-uint32(cumsum(isolated));
        stripData(isolated)=[];
    end
end

function[cutParameters_k,n,breaks]=wrapLoops(cutParameters_k,n,breaks)



    if numel(breaks)>1&&...
        cutParameters_k.XData(1)==cutParameters_k.XData(end)&&...
        cutParameters_k.YData(1)==cutParameters_k.YData(end)

        cut=breaks(1);
        cutParameters_k.XData=cutParameters_k.XData([cut+1:end,2:cut-1]);
        cutParameters_k.YData=cutParameters_k.YData([cut+1:end,2:cut-1]);
        n=n([cut+1:end,2:cut-1]);
        breaks=[breaks(2:end-1)-cut,breaks(end)-2];
    end

end

function[labelParameters,cutParameters]=placeLabelsForSinglePart(x,y,...
    level,label,labelWidth,labelSpacing,axesInfo,cutContoursAtLabels)




    labelParameters=initializeLabelParameters;
    if cutContoursAtLabels
        cutParameters=struct('XData',x,'YData',y,'Level',level);
    else
        cutParameters=struct('XData',cell(1,0),'YData',[],'Level',[]);
    end


    xLimits=axesInfo.XLimits;
    xScale=axesInfo.XScale;
    xDir=axesInfo.XDir;
    xLog=axesInfo.XLog;
    yLimits=axesInfo.YLimits;
    yScale=axesInfo.YScale;
    yDir=axesInfo.YDir;
    yLog=axesInfo.YLog;


    [xTransformed,xInv]=adjustForLogScale(x,xLog);
    [yTransformed,yInv]=adjustForLogScale(y,yLog);


    d=[0,hypot(diff(xScale*xTransformed),diff(yScale*yTransformed))];


    section=cumsum(isnan(d));
    d(isnan(d))=0;
    d=cumsum(d);

    n=numel(xTransformed);
    labelHalfWidth=labelWidth/2;
    contourLength=max(0,d(n)-3*labelHalfWidth);
    slop=contourLength-labelSpacing*floor(contourLength/labelSpacing);


    randomValue=getRandomValue();
    start=1.5*labelHalfWidth+max(labelHalfWidth,slop)*randomValue;
    psn=start:labelSpacing:d(n)-1.5*labelHalfWidth;
    lp=size(psn,2);

    if(lp>0)&&isfinite(level)
        Ic=sum(d(ones(1,lp),:)'<psn(ones(1,n),:),1);
        Il=sum(d(ones(1,lp),:)'<=psn(ones(1,n),:)-labelHalfWidth,1);
        Ir=sum(d(ones(1,lp),:)'<psn(ones(1,n),:)+labelHalfWidth,1);


        out=(Ir<1|Ir>length(d)-1)...
        |(Il<1|Il>length(d)-1)...
        |(Ic<1|Ic>length(d)-1);

        Ir=max(1,min(Ir,length(d)-1));
        Il=max(1,min(Il,length(d)-1));
        Ic=max(1,min(Ic,length(d)-1));


        Il(out)=Ic(out);
        Ir(out)=Ic(out);


        bad=(section(Il)~=section(Ir));
        Il(bad)=[];
        Ir(bad)=[];
        Ic(bad)=[];
        psn(:,bad)=[];
        out(bad)=[];
        in=~out;

        if~isempty(Il)

            wl=(d(Il+1)-psn+labelHalfWidth.*in)./(d(Il+1)-d(Il));
            wr=(psn-labelHalfWidth.*in-d(Il))./(d(Il+1)-d(Il));
            xl=xTransformed(Il).*wl+xTransformed(Il+1).*wr;
            yl=yTransformed(Il).*wl+yTransformed(Il+1).*wr;

            wl=(d(Ir+1)-psn-labelHalfWidth.*in)./(d(Ir+1)-d(Ir));
            wr=(psn+labelHalfWidth.*in-d(Ir))./(d(Ir+1)-d(Ir));
            xr=xTransformed(Ir).*wl+xTransformed(Ir+1).*wr;
            yr=yTransformed(Ir).*wl+yTransformed(Ir+1).*wr;


            wl=(d(Ic+1)-psn)./(d(Ic+1)-d(Ic));
            wr=(psn-d(Ic))./(d(Ic+1)-d(Ic));
            xc=xTransformed(Ic).*wl+xTransformed(Ic+1).*wr;
            yc=yTransformed(Ic).*wl+yTransformed(Ic+1).*wr;


            shiftfrac=.5;

            xc=(1-shiftfrac)*xc+shiftfrac*(xr+xl)/2;
            yc=(1-shiftfrac)*yc+shiftfrac*(yr+yl)/2;


            outOfBounds=~isreal(xc)|~isreal(yc)|...
            (xc<xLimits(1))|...
            (xc>xLimits(2))|...
            (yc<yLimits(1))|...
            (yc>yLimits(2));

            xc(outOfBounds)=[];
            yc(outOfBounds)=[];
            xr(outOfBounds)=[];
            yr(outOfBounds)=[];
            xl(outOfBounds)=[];
            yl(outOfBounds)=[];
            Ir(outOfBounds)=[];
            Il(outOfBounds)=[];
            psn(outOfBounds)=[];
            lp=length(Il);




            trot=atan2d((yr-yl)*yDir*yScale,(xr-xl)*xDir*xScale);
            backang=(abs(trot)>90);
            trot(backang)=trot(backang)+180;

            labelParameters=initializeLabelParameters(lp);
            for jj=1:lp
                labelParameters(1,jj).String=label;




                if(xLog||yLog)
                    labelParameters(1,jj).Position=[xInv(xc(jj)),yInv(yc(jj)),0];
                else
                    labelParameters(1,jj).Position=[xc(jj),yc(jj),0];
                end
                labelParameters(1,jj).Rotation=trot(jj);
                labelParameters(1,jj).Level=level;
            end

            if cutContoursAtLabels



                dr=d(Ir)+hypot((xr-xTransformed(Ir))*xScale,(yr-yTransformed(Ir))*yScale);
                dl=d(Il)+hypot((xl-xTransformed(Il))*xScale,(yl-yTransformed(Il))*yScale);


                f1=accumarray([ones(lp,1),Il.'],ones(1,lp),[1,n]);
                f2=accumarray([ones(lp,1),Ir.'],ones(1,lp),[1,n]);
                irem=find(cumsum(f1)-cumsum(f2))+1;
                x(irem)=[];
                y(irem)=[];
                d(irem)=[];
                n=n-size(irem,2);



                nans=NaN(size(xc));
                xf=[x(1:n),xInv(xl),nans,xInv(xr)];
                yf=[y(1:n),yInv(yl),nans,yInv(yr)];

                [~,indices]=sort([d(1:n),dl,psn,dr]);

                xf=xf(indices);
                yf=yf(indices);

                cutParameters=struct(...
                'XData',xf,...
                'YData',yf,...
                'Level',level);
            end
        end
    end
end

function labelWidth=getLabelWidth(updateState,label,fontObj)
    str=char(label+"9");
    bounds=updateState.getStringBounds(str,fontObj,'none','off');
    labelWidth=bounds(1);
end

function labelParameters=initializeLabelParameters(num)

    if nargin==0||num==0
        labelParameters=struct('String',[],'Position',[],'Rotation',[],'Level',[]);
        labelParameters(1)=[];
    else
        labelParameters(1,num)=struct('String',[],'Position',[],'Rotation',[],'Level',[]);
    end
end

function r=getRandomValue()

    dflt=RandStream.getGlobalStream();
    savedState=dflt.State;
    r=rand(1);
    dflt.State=savedState;
end

function info=collectAxesInfo(updateState)






    axesPosition=computeViewportSize(updateState);

    xLimits=updateState.DataSpace.XLim;
    yLimits=updateState.DataSpace.YLim;
    centralPoint=[sum(xLimits),sum(yLimits),0]/2;





    xLog=double(strcmp(updateState.DataSpace.XScale,'log')).*sign(xLimits(2));
    yLog=double(strcmp(updateState.DataSpace.YScale,'log')).*sign(yLimits(2));

    xLimits=adjustForLogScale(xLimits,xLog);
    yLimits=adjustForLogScale(yLimits,yLog);

    xScale=axesPosition(3)/diff(xLimits);
    yScale=axesPosition(4)/diff(yLimits);

    xDir=1;
    yDir=1;
    if~isempty(centralPoint)
        j=GetJacobian(updateState.DataSpace,centralPoint);
        if j(1,1)<0
            xDir=-1;
        end
        if j(2,2)<0
            yDir=-1;
        end
    end

    info=struct(...
    'XLimits',xLimits,'XScale',xScale,'XDir',xDir,'XLog',xLog,...
    'YLimits',yLimits,'YScale',yScale,'YDir',yDir,'YLog',yLog);
end

function PA=computeViewportSize(updateState)
    v=updateState.Camera.Viewport;
    v.Units='points';
    PA=v.Position;
end

function[data,invFcn]=adjustForLogScale(data,scale)





    if scale==1
        data=log(data);
        invFcn=@(in)exp(in);
    elseif scale==-1
        data=-log(-data);
        invFcn=@(in)-exp(-in);
    else
        invFcn=@(in)in;
    end

end
