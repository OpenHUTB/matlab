function data=calcXYZData(hObj,xlims,us,transformation)




    gran=hObj.MeshDensity;
    data=struct('xdata_coarse',[],'xdata',[],...
    'ydata_coarse',[],'ydata',[],...
    'zdata_coarse',[],'zdata',[],...
    'poles',hObj.findPoles,...
    'invalidInScale',[],...
    'vbox',[],...
    'LineVertices',[],'LineStripData',[]);

    if gran<1||length(xlims)<2
        return
    end



    scale='';
    if~isempty(us)&&isa(us.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
        scale=us.DataSpace.XScale;
    end
    x=matlab.graphics.function.internal.initialMesh(hObj,xlims,gran,scale);

    if isempty(hObj.Function_fh_I)
        hObj.updateFunction;
    end
    fn=hObj.Function_fh_I;

    if isa(hObj.Function,'sym')
        try
            data.poles=polesFromCache(hObj,xlims);
        catch
        end
    end





    function[x,y]=evaluateAt(x)
        try
            y=double(fn(x));

            if isscalar(y)&&~isscalar(x)
                y=repmat(y,size(x));
            end
        catch me
            error(message('MATLAB:FunctionLine:doUpdate',me.message));
        end

        nanPos=reject(hObj,x,y);
        if any(nanPos)

            rndStream=RandStream('mt19937ar','Seed',12345);
            x(nanPos)=x(nanPos)+rndStream.randn([1,sum(nanPos)])*(xlims(2)-xlims(1))/(100*gran);
            if x(1)<xlims(1)
                x(1)=xlims(1)+(xlims(1)-x(1));
            end
            if x(end)>xlims(2)
                x(end)=xlims(2)-(x(end)-xlims(2));
            end
            try
                y(nanPos)=double(fn(x(nanPos)));
            catch me
                error(message('MATLAB:FunctionLine:doUpdate',me.message));
            end
        end

        nanPos=reject(hObj,x,y);
        data.poles=union(data.poles,x(nanPos));


        if~isempty(us)&&isa(us.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
            yIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            us.DataSpace.YScale,us.DataSpace.YLim,y);

            for pos=find(yIsInvalid)
                if pos>1&&~yIsInvalid(pos-1)
                    goal=1e-10*sign(y(pos-1));
                    if abs(y(pos-1))>abs(goal)
                        [x0,y0,exitflag]=fzero(@(x)fn(x)-goal,[x(pos-1),x(pos)]);
                        if exitflag==1&&~any(x==x0)
                            x(pos)=x0;
                            y(pos)=y0+goal;
                            yIsInvalid(pos)=false;
                        end
                    end
                elseif pos<numel(y)&&~yIsInvalid(pos+1)
                    goal=1e-10*sign(y(pos+1));
                    if abs(y(pos+1))>abs(goal)
                        [x0,y0,exitflag]=fzero(@(x)fn(x)-goal,[x(pos),x(pos+1)]);
                        if exitflag==1&&~any(x==x0)
                            x(pos)=x0;
                            y(pos)=y0+goal;
                            yIsInvalid(pos)=false;
                        end
                    end
                end
            end
        else
            yIsInvalid=false(size(y));
        end

        data.invalidInScale=union(data.invalidInScale,x(yIsInvalid));

        y(yIsInvalid|nanPos)=nan;
    end

    function[newx,newy,idxs]=addPointsAt(newx)
        [newx,newy]=evaluateAt(newx);
        [x,idxs]=unique([x,newx]);
        y=[y,newy];
        y=y(idxs);
    end



    [x,y]=evaluateAt(x);
    z=zeros(size(x));

    data.xdata_coarse=x;
    data.ydata_coarse=y;
    data.zdata_coarse=z;




    rndStream=RandStream('mt19937ar','Seed',1234);
    newx=x(1:end-1)+(rndStream.randn([1,numel(x)-1])/23+1/2)*(x(2)-x(1));
    addPointsAt(newx);

    if isa(hObj.Function,'sym')
        try
            newx=derivativePolesFromCache(hObj,xlims);
            addPointsAt(newx);
        catch
        end
    end

    z=zeros(size(x));



    pixelLocations=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,[x;y;z]);
    pixelLocations(:,isnan(x))=nan;
    maxtan=tand(5);
    for adaptiveRound=2:hObj.AdaptiveMeshDensity

        slopes=diff(pixelLocations(2,:))./diff(pixelLocations(1,:));



        a1=slopes(1:end-1);
        a2=slopes(2:end);
        relslopes=(a2-a1)./(a1.*a2.*(abs(a2-a1)<1)+1);
        refineAround=find(abs(relslopes)>maxtan|~isfinite(relslopes)|imag(relslopes)~=0);
        if isempty(refineAround)
            break;
        end
        addPointAfterIdx=union(refineAround,refineAround+1);
        [newx,newy,idxs]=addPointsAt(arrayfun(@(i)(x(i+1)+x(i))/2,addPointAfterIdx));
        newz=zeros(size(newx));
        newPixelLocations=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,[newx;newy;newz]);
        newPixelLocations(:,isnan(newy))=nan;
        pixelLocations=[pixelLocations,newPixelLocations];%#ok<AGROW>
        pixelLocations=pixelLocations(:,idxs);
    end





    poleCandidates=matlab.graphics.function.internal.findPoles(y,pixelLocations(1,:),pixelLocations(2,:),[]);


    data.poles=reshape(union(data.poles,x(poleCandidates)),1,[]);
    nanPos=poleCandidates|~isfinite(y)|(imag(y)~=0);
    y(nanPos)=nan;





    validX=x(~nanPos);
    if numel(data.poles)>1
        removePoles=[false...
        ,~arrayfun(...
        @(i)any((validX>data.poles(i-1))&(validX<data.poles(i+1))),...
        2:numel(data.poles)-1)...
        ,false];
        data.poles(removePoles)=[];
        if numel(data.poles)>1&&~any(validX<data.poles(2))
            data.poles(1)=[];
        end
        if numel(data.poles)>1&&~any(validX>data.poles(end-1))
            data.poles(end)=[];
        end
    end

    if numel(data.invalidInScale)>1
        removePoles=[false...
        ,~arrayfun(...
        @(i)any((validX>data.invalidInScale(i-1))&(validX<data.invalidInScale(i+1))),...
        2:numel(data.invalidInScale)-1)...
        ,false];
        data.invalidInScale(removePoles)=[];
        if numel(data.invalidInScale)>1&&~any(validX<data.invalidInScale(2))
            data.invalidInScale(1)=[];
        end
        if numel(data.invalidInScale)>1&&~any(validX>data.invalidInScale(end-1))
            data.invalidInScale(end)=[];
        end
    end






    if isempty(data.poles)||isempty(x(~nanPos))
        vboxInclude=true(size(x));
    else
        vboxInclude=all(abs(bsxfun(@minus,x,data.poles.'))>(max(x)-min(x))/100,1);



    end
    transdata=[x(vboxInclude&~nanPos);y(vboxInclude&~nanPos)];
    if isempty(transdata)
        transdata=reshape(transdata,2,[]);
    end
    transdata=[transdata;zeros(1,size(transdata,2));ones(1,size(transdata,2))];
    transdata=transformation*transdata;


    data.vbox=[...
    matlab.graphics.function.internal.estimateViewingBox(transdata(1,:),-inf,inf,false);...
    matlab.graphics.function.internal.estimateViewingBox(transdata(2,:),-inf,inf,false);...
    matlab.graphics.function.internal.estimateViewingBox(transdata(3,:),-inf,inf,false)...
    ];
    if isequal(double(transformation),eye(4))&&strcmp(hObj.XRangeMode,'manual')
        data.vbox(1,:)=matlab.graphics.chart.primitive.utilities.arraytolimits([xlims,data.vbox(1,:)]);
    end

    x(nanPos)=[];
    y(nanPos)=[];

    if~strcmp(hObj.Marker,'none')&&numel(x)>1
        peaksHigh=y(2:end-1)>y(1:end-2)&y(2:end-1)>y(3:end);
        peaksLow=y(2:end-1)<y(1:end-2)&y(2:end-1)<y(3:end);
        show=[true,(peaksHigh|peaksLow),true];
        showPos=x(show);
        data.xdata_coarse=showPos;
        targetNumber=16;
        targetDist=(xlims(2)-xlims(1))/targetNumber;

        maxDist=(xlims(2)-xlims(1))/500;

        for k=numel(showPos)-1:-1:1
            left=showPos(k);
            right=showPos(k+1);
            rangeWidth=right-left;

            additional=floor(rangeWidth/targetDist);
            addNear=linspace(left,right,additional+2);
            needPoint=arrayfun(@(x0)min(abs(x-x0))>maxDist,addNear);
            addPointsAt(addNear(needPoint));
            for n=1:numel(addNear)
                [~,idx]=min(abs(x-addNear(n)));
                addNear(n)=x(idx);
            end
            data.xdata_coarse=[data.xdata_coarse,addNear];
        end

        data.xdata_coarse=sort(data.xdata_coarse);
        data.ydata_coarse=arrayfun(@(x0)y(x==x0),data.xdata_coarse);
        data.zdata_coarse=zeros(size(data.xdata_coarse));


        markers=[data.xdata_coarse;data.ydata_coarse;data.zdata_coarse];
        markers=[markers;matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,markers)];
        mindist=hObj.MarkerSize*1.2;
        if isa(us,'matlab.graphics.eventdata.UpdateState')
            mindist=mindist*us.PixelsPerPoint;
        end

        i=2;
        while i<size(markers,2)
            dists=bsxfun(@minus,markers(4:5,1:(i-1)),markers(4:5,i));
            dists=dists(1,:).^2+dists(2,:).^2;
            if any(dists<mindist^2)
                markers(:,i)=[];
            else
                i=i+1;
            end
        end

        data.xdata_coarse=markers(1,:);
        data.ydata_coarse=markers(2,:);
        data.zdata_coarse=markers(3,:);
    end

    data.xdata=x;
    data.ydata=y;
    data.zdata=zeros(size(x));
end

function nanPos=reject(~,~,y)
    nanPos=~isfinite(y)|(imag(y)~=0);
end

function polePositions=polesFromCache(hObj,xlims)
    state=warning('off','symbolic:sym:poles:CannotDeterminePoles');
    tmp=onCleanup(@()warning(state));
    if isempty(hObj.FunctionPoleCache)
        polePositions=double(poles(hObj.Function,symvar(hObj.Function),xlims(1),xlims(2)));
        cachedRange=xlims;
    else
        polePositions=hObj.FunctionPoleCache{1};
        cachedRange=hObj.FunctionPoleCache{2};
        if xlims(1)<cachedRange(1)
            polePositions=[double(poles(hObj.Function,symvar(hObj.Function),xlims(1),cachedRange(1))),polePositions];
            cachedRange(1)=xlims(1);
        end
        if xlims(2)>cachedRange(2)
            polePositions=[polePositions,double(poles(hObj.Function,symvar(hObj.Function),cachedRange(2),xlims(2)))];
            cachedRange(2)=xlims(2);
        end
    end
    polePositions=polePositions(:).';
    hObj.FunctionPoleCache={polePositions,cachedRange};
    polePositions=polePositions(polePositions>xlims(1)&polePositions<xlims(2));
end

function newx=derivativePolesFromCache(hObj,xlims)
    xvar=symvar(hObj.Function);
    if isempty(xvar)
        newx=[];
        return;
    end
    dF=[];
    state=warning('off','symbolic:sym:poles:CannotDeterminePoles');
    tmp=onCleanup(@()warning(state));
    if isempty(hObj.FunctionDerivativePoleCache)
        dF=diff(hObj.Function,xvar);
        newx=double(poles(dF,xvar,xlims(1),xlims(2)));
        cachedRange=xlims;
    else
        newx=hObj.FunctionDerivativePoleCache{1};
        cachedRange=hObj.FunctionDerivativePoleCache{2};
        if xlims(1)<cachedRange(1)
            dF=diff(hObj.Function,xvar);
            newx=[double(poles(dF,xvar,xlims(1),cachedRange(1))),newx];
            cachedRange(1)=xlims(1);
        end
        if xlims(2)>cachedRange(2)
            if isempty(dF)
                dF=diff(hObj.Function,xvar);
            end
            newx=[newx,double(poles(dF,xvar,cachedRange(2),xlims(2)))];
            cachedRange(2)=xlims(2);
        end
    end
    newx=newx(:).';
    hObj.FunctionDerivativePoleCache={newx,cachedRange};
    newx=newx(newx>xlims(1)&newx<xlims(2));
end
