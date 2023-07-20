function data=calcXYZData(hObj,us,infoStruct)




    gran=hObj.MeshDensity;
    xlims=hObj.TRange;
    data=struct('xdata_coarse',[],'xdata',[],...
    'ydata_coarse',[],'ydata',[],...
    'zdata_coarse',[],'zdata',[],...
    'tdata_coarse',[],'tdata',[],...
    'poles',[],...
    'invalidInScale',[],...
    'vbox',[],...
    'LineVertices',[],'LineStripData',[]);
    if gran<1||length(xlims)<2
        return
    end


    t=linspace(xlims(1),xlims(2),gran);
    if isempty(hObj.XFunction_fh_I)||isempty(hObj.YFunction_fh_I)||isempty(hObj.ZFunction_fh_I)
        hObj.updateFunctionHandles;
    end
    fnX=hObj.XFunction_fh_I;
    fnY=hObj.YFunction_fh_I;
    if isempty(hObj.ZFunction)
        fnZ=@(t)0;
    else
        fnZ=hObj.ZFunction_fh_I;
    end

    if isa(us,'matlab.graphics.eventdata.UpdateState')
        ds=us.DataSpace;
    elseif isa(us,'matlab.graphics.axis.dataspace.DataSpace')
        ds=us;
    else
        ds=hObj.getDataSpace;
    end






    function[t,x,y,z]=evaluateAt(t)
        try
            x=double(fnX(t));
            y=double(fnY(t));
            z=double(fnZ(t));

            if isscalar(x)&&~isscalar(t)
                x=repmat(x,size(t));
            end
            if isscalar(y)&&~isscalar(t)
                y=repmat(y,size(t));
            end
            if isscalar(z)&&~isscalar(t)
                z=repmat(z,size(t));
            end
        catch me
            error(message('MATLAB:FunctionLine:doUpdate',me.message));
        end

        nanPos=reject(hObj,x,y,z);
        if any(nanPos)
            data.poles=union(data.poles,t(nanPos));
            rndStream=RandStream('mt19937ar','Seed',12345);
            t(nanPos)=t(nanPos)+rndStream.randn([1,sum(nanPos)])*(xlims(2)-xlims(1))/(100*gran);
            if t(1)<xlims(1)
                t(1)=xlims(1)+(xlims(1)-t(1));
            end
            if t(end)>xlims(2)
                t(end)=xlims(2)-(t(end)-xlims(2));
            end
            try
                x(nanPos)=double(fnX(t(nanPos)));
                y(nanPos)=double(fnY(t(nanPos)));
                z(nanPos)=double(fnZ(t(nanPos)));
            catch me
                error(message('MATLAB:FunctionLine:doUpdate',me.message));
            end
        end

        nanPos=reject(hObj,x,y,z);
        data.poles=union(data.poles,t(nanPos));


        if~isempty(ds)&&isa(ds,'matlab.graphics.axis.dataspace.CartesianDataSpace')
            xIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            ds.XScale,ds.XLim,x);
            yIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            ds.YScale,ds.YLim,y);
            zIsInvalid=...
            matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            ds.ZScale,ds.ZLim,z);
        else
            xIsInvalid=false(size(x));
            yIsInvalid=false(size(y));
            zIsInvalid=false(size(z));
        end
        data.invalidInScale=union(data.invalidInScale,t(xIsInvalid|yIsInvalid|zIsInvalid));

        x(xIsInvalid|yIsInvalid|zIsInvalid)=nan;
        y(xIsInvalid|yIsInvalid|zIsInvalid)=nan;
        z(xIsInvalid|yIsInvalid|zIsInvalid)=nan;
    end

    function[newt,newx,newy,newz,idxs]=addPointsAt(newt)
        [newt,newx,newy,newz]=evaluateAt(newt);
        [t,idxs]=unique([t,newt]);
        x=[x,newx];
        x=x(idxs);
        y=[y,newy];
        y=y(idxs);
        z=[z,newz];
        z=z(idxs);
    end



    [t,x,y,z]=evaluateAt(t);

    data.xdata_coarse=x;
    data.ydata_coarse=y;
    data.zdata_coarse=z;
    data.tdata_coarse=t;




    rndStream=RandStream('mt19937ar','Seed',1234);
    newt=t(1:end-1)+(rndStream.randn([1,numel(t)-1])/23+1/2)*(t(2)-t(1));
    addPointsAt(newt);



    pixelLocations=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,[x;y;z]);
    pixelLocations(:,isnan(x))=nan;
    maxtan=tand(3);
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
        [~,newx,newy,newz,idxs]=addPointsAt(arrayfun(@(i)(t(i+1)+t(i))/2,addPointAfterIdx));
        newPixelLocations=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj,[newx;newy;newz]);
        newPixelLocations(:,isnan(newx))=nan;
        pixelLocations=[pixelLocations,newPixelLocations];%#ok<AGROW>
        pixelLocations=pixelLocations(:,idxs);
    end

    hascomplex=(imag(x)~=0)|(imag(y)~=0)|(imag(z)~=0);
    x(hascomplex)=nan;
    y(hascomplex)=nan;
    z(hascomplex)=nan;

    [~,~,hDataSpace,belowMatrix]=matlab.graphics.internal.getSpatialTransforms(hObj);
    worldCoordinates=matlab.graphics.internal.transformDataToWorld(hDataSpace,belowMatrix,[x;y;z]);

    for field=["XConstraints","YConstraints","ZConstraints"]
        if~isfield(infoStruct,field)


            infoStruct.(field)=[];
        end
    end
    poleCandidates=matlab.graphics.function.internal.findPoles(x,t,worldCoordinates(1,:),infoStruct.XConstraints);
    poleCandidates=poleCandidates|matlab.graphics.function.internal.findPoles(y,t,worldCoordinates(2,:),infoStruct.YConstraints);
    poleCandidates=poleCandidates|matlab.graphics.function.internal.findPoles(z,t,worldCoordinates(3,:),infoStruct.ZConstraints);


    data.poles=reshape(union(data.poles,t(poleCandidates)),1,[]);
    nanPos=poleCandidates|~isfinite(x)|~isfinite(y)|~isfinite(z);
    x(nanPos)=nan;
    y(nanPos)=nan;
    z(nanPos)=nan;





    if numel(data.poles)>1
        removePoles=[false,~arrayfun(@(i)any((x>data.poles(i-1))&(x<data.poles(i+1))),2:numel(data.poles)-1),false];
        data.poles(removePoles)=[];
        if numel(data.poles)>1&&~any(x<data.poles(2))
            data.poles(1)=[];
        end
        if numel(data.poles)>1&&~any(x>data.poles(end-1))
            data.poles(end)=[];
        end
    end

    if numel(data.invalidInScale)>1
        removePoles=[false,~arrayfun(@(i)any((x>data.invalidInScale(i-1))&(x<data.invalidInScale(i+1))),2:numel(data.invalidInScale)-1),false];
        data.invalidInScale(removePoles)=[];
        if numel(data.invalidInScale)>1&&~any(x<data.invalidInScale(2))
            data.invalidInScale(1)=[];
        end
        if numel(data.invalidInScale)>1&&~any(x>data.invalidInScale(end-1))
            data.invalidInScale(end)=[];
        end
    end

    nanPos=~isfinite(x)|(imag(x)~=0)|~isfinite(y)|(imag(y)~=0)|~isfinite(z)|(imag(z)~=0);

    t(nanPos)=[];
    x(nanPos)=[];
    y(nanPos)=[];
    z(nanPos)=[];

    data.tdata=t;
    data.xdata=x;
    data.ydata=y;
    data.zdata=z;
end

function nanPos=reject(~,x,y,z)
    nanPos=~isfinite(x)|(imag(x)~=0)|...
    ~isfinite(y)|(imag(y)~=0)|...
    ~isfinite(z)|(imag(z)~=0);
end
