function data=calcXYData(hObj,us)




    xlims=hObj.XRange;
    ylims=hObj.YRange;

    transformation=eye(4);
    lims=[];

    if isa(us,'matlab.graphics.eventdata.UpdateState')
        ds=us.DataSpace;
        lims=[ds.XLim;ds.YLim;ds.ZLim];
        transformation=us.Transform;
    else
        if isa(us,'matlab.graphics.axis.dataspace.DataSpacee')
            ds=us;
        else
            ds=getDataSpace(hObj);
        end


        try
            if~strcmp(ds.XLimMode,'auto')
                lims(1,:)=ds.XLim;
            end
            if~strcmp(ds.YLimMode,'auto')
                lims(2,:)=ds.YLim;
            end
            if~strcmp(ds.ZLimMode,'auto')
                lims(3,:)=ds.ZLim;
            end
        catch
        end
    end

    if~isequal(transformation,eye(4))
        corners=[repelem(lims(1,:),1,2);repmat(lims(2,:),1,2)];
        corners=[repelem(corners,1,2);repmat(lims(3,:),1,4);ones(1,8)];
        backtransformed=transformation\corners;
        vbox=[min(backtransformed,[],2),max(backtransformed,[],2)];
        if~any(isnan(vbox),'all')
            lims=vbox(1:3,:)./vbox(4,:);
        end
    end

    if~isempty(lims)
        xlimUs=lims(1,:);
        if hObj.XRangeMode=="auto"
            xlims=xlimUs;
        else
            xlims=[max(xlims(1),xlimUs(1)),min(xlims(2),xlimUs(2))];
        end
        ylimUs=lims(2,:);
        if hObj.YRangeMode=="auto"
            ylims=ylimUs;
        else
            ylims=[max(ylims(1),ylimUs(1)),min(ylims(2),ylimUs(2))];
        end
    end

    if strcmp(hObj.XRangeMode,'auto')
        hObj.XRange_I=xlims;
    end
    if strcmp(hObj.YRangeMode,'auto')
        hObj.YRange_I=ylims;
    end

    data=struct('xdata_coarse',[],'xdata',[],...
    'ydata_coarse',[],'ydata',[],...
    'zdata_coarse',[],'zdata',[],...
    'poles',[],...
    'invalidInScale',[],...
    'contourlines',struct(...
    'LineVertices',{},'LineStripData',{},...
    'Level',{}),...
    'vbox',[xlims;ylims;0,0]);

    gran=hObj.MeshDensity;
    if gran<1
        return
    end


    scaleX='';
    scaleY='';
    if~isempty(us)&&isa(us.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
        scaleX=us.DataSpace.XScale;
        scaleY=us.DataSpace.YScale;
    end
    x=matlab.graphics.function.internal.initialMesh(hObj,xlims,gran,scaleX);
    y=matlab.graphics.function.internal.initialMesh(hObj,ylims,gran,scaleY);

    if isempty(hObj.Function_fh_I)
        hObj.updateFunction;
    end
    fn=hObj.Function_fh_I;

    [x,y]=meshgrid(x,y);
    z=reshape(double(fn(x(:).',y(:).')),size(x));

    z(imag(z)~=0)=nan;

    if size(z)~=size(x)
        z=reshape(z,size(x));
        warning(message('MATLAB:fcontour:BadResultShape'));
        if size(z)~=size(x)
            error(message('MATLAB:fcontour:BadResultShape'));
        end
    end

    data.xdata_coarse=x;
    data.ydata_coarse=y;
    data.zdata_coarse=z;

    levelList=getLevelListImpl(hObj,z);

    contourLines=matlab.graphics.chart.internal.contour.contourGriddedData(...
    x,y,z,levelList,true);


    data.xdata=data.xdata_coarse;
    data.ydata=data.ydata_coarse;
    data.zdata=data.zdata_coarse;

    data.contourlines=contourLines;
end

function levelList=getLevelListImpl(hObj,zdata)
    if strcmp(hObj.LevelListMode,'auto')
        zdata=zdata(:);
        zdata(~isfinite(zdata))=[];
        zmin=0;
        zmax=0;
        if~isempty(zdata)
            zmin=min(zdata);
            zmax=max(zdata);
        end
        if zmin~=zmax
            step=getLevelStepImpl(hObj,zmin,zmax);
            if step>0
                newValue=getContourList(hObj,zmin,zmax,step);
                if strcmp(hObj.Fill,'on')&&(newValue(1)~=zmin)
                    newValue=[zmin,newValue];
                end
                levelList=newValue;
            else
                levelList=[];
            end
        else
            levelList=[];
        end
    else
        levelList=hObj.LevelList_I;
    end
end

function levelStep=getLevelStepImpl(hObj,zmin,zmax)
    if strcmp(hObj.LevelStepMode,'auto')
        if zmin~=zmax
            zrange=zmax-zmin;
            zrange10=10^(floor(log10(zrange)));
            nsteps=zrange/zrange10;
            if nsteps<1.2
                zrange10=zrange10/10;
            elseif nsteps<2.4
                zrange10=zrange10/5;
            elseif nsteps<6
                zrange10=zrange10/2;
            end
            levelStep=zrange10;
        else
            levelStep=0;
        end
    else
        levelStep=hObj.LevelStep_I;
    end
end

function outList=getContourList(~,zmin,zmax,step)





    if zmin<0&&zmax>0
        neg=-step:-step:zmin;
        pos=0:step:zmax;
        outList=[fliplr(neg),pos];
    elseif zmin<0
        start=zmin-(step-mod(-zmin,step));
        outList=start+step:step:zmax;
    else
        start=zmin+(step-mod(zmin,step));
        outList=start:step:zmax;
    end
end

function ds=getDataSpace(hObj)
    ds=ancestor(hObj,'matlab.graphics.axis.dataspace.DataSpace','node');
end
