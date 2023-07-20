function r=getRemeshParams(obj,Hmin,Hmax,Mesh)
    m=Mesh;
    warnflag=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');

    TR=triangulation(m.Triangles(1:3,:)',m.Points');
    warning(warnflag);

    ptID=featureEdges(TR,pi/6);
    ptID=unique(ptID(:));
    borderPoints=TR.Points(ptID,:);
    maxAlongx=max(borderPoints(:,1));
    minAlongx=min(borderPoints(:,1));
    maxAlongy=max(borderPoints(:,2));
    minAlongy=min(borderPoints(:,2));
    maxAlongz=max(borderPoints(:,3));
    minAlongz=min(borderPoints(:,3));
    dx=maxAlongx-minAlongx;
    dy=maxAlongy-minAlongy;
    dz=maxAlongz-minAlongz;
    dedges=vecnorm(diff(borderPoints,1)');

    if~isHminUserSpecified(obj)
        if Hmin>Hmax
            Hmin=Hmax;
        end






        if all(strcmpi(getMeshMode(obj),'manual'))
            if isempty(Hmin)
                checkant={'discone','monocone','dipole','dipoleFolded'};
                if Hmax>max(dedges)
                    Hmin=0.5*mean(dedges);
                elseif any(strcmpi(class(obj),checkant))



                    Hmin=0.3*Hmax;
                end
                if any(strcmpi(class(obj),checkant))
                    setMeshMinContourEdgeLength(obj,Hmin);
                end
            end
        end
        flag=Hmin>max(dedges);
        if~isa(obj,'spiralArchimedean')&&~isempty(Hmin)&&any(flag(:))&&~isa(obj,'waveguideRidge')


            Hmin=0.5*mean(dedges);
        end
    else
        if Hmin>Hmax
            error(message('antenna:antennaerrors:HminLessThanHmax',...
            num2str(Hmax)));
        end
    end

    Htarget=getTargetInteriorEdgeLength(obj);
    if isempty(Htarget)
        Htarget=0;
    end

    r.Hmin=Hmin;
    r.Hmax=Hmax;
    r.Hgrad=getNewMesherGrowthRate(obj);
    r.Htarget=Htarget;
    r.Hsubdomain=obj.MesherStruct.Mesh.FeedWidth(1);
    r.feedpoint=obj.FeedLocation;
end