function[x,y,z,isxz,isyz]=create_bar_coordinates(xedges,yedges,...
    values,dropzero,isInfEdgeX,isInfEdgeY,basevalues)





    countslenx=length(xedges)-1;
    countsleny=length(yedges)-1;

    if nargin<5
        isInfEdgeX=isinf(xedges);
    end
    if nargin<6
        isInfEdgeY=isinf(yedges);
    end

    xedgesNoInf=xedges(~isInfEdgeX);
    yedgesNoInf=yedges(~isInfEdgeY);

    if nargin>6&&~isempty(basevalues)
        nonzerobase=true;
    else
        nonzerobase=false;
    end


    if length(yedgesNoInf)<2
        xz_x=[];
        xz_y=[];
        xz_z=[];
    else
        xz_x=repelem(xedges,4);
        xz_x=xz_x(3:end-2);
        xz_y=reshape(repelem(yedgesNoInf,length(xz_x)),4,[]);
        valuesXZ=values;
        if isInfEdgeY(1)
            valuesXZ(:,1)=[];
        end
        if isInfEdgeY(end)
            valuesXZ(:,end)=[];
        end
        fliporientation=(valuesXZ(:,1:end-1)>valuesXZ(:,2:end))|...
        isnan(valuesXZ(:,2:end));
        xz_xtemp=reshape(repmat(xz_x,1,length(yedgesNoInf)-2),4,[]);
        xz_xtemp(:,fliporientation)=flipud(xz_xtemp(:,fliporientation));
        xz_x=reshape([xz_x,reshape(xz_xtemp,1,[]),flip(xz_x)],4,[]);
        xz_z=reshape([valuesXZ(:,1),max(valuesXZ(:,1:end-1),...
        valuesXZ(:,2:end)),valuesXZ(end:-1:1,end)],1,[]);
    end

    if nonzerobase
        basevaluesXZ=basevalues;
        if isInfEdgeY(1)
            basevaluesXZ(:,1)=[];
        end
        if isInfEdgeY(end)
            basevaluesXZ(:,end)=[];
        end
        xz_zbase=reshape([basevaluesXZ(:,1),max(basevaluesXZ(:,1:end-1),...
        basevaluesXZ(:,2:end)),basevaluesXZ(end:-1:1,end)],1,[]);
    else
        xz_zbase=zeros(1,length(xz_z));
    end
    xz_z=[xz_zbase;xz_z;xz_z;...
    xz_zbase];

    if dropzero

        zzero=~(xz_z(2,:)>0);
        xz_x(:,zzero)=[];
        xz_y(:,zzero)=[];
        xz_z(:,zzero)=[];
    end


    if nonzerobase
        zbase=xz_z(1,:)==xz_z(2,:);
        if~dropzero
            zbase=zbase&(xz_z(2,:)>0);
        end
        xz_x(:,zbase)=[];
        xz_y(:,zbase)=[];
        xz_z(:,zbase)=[];
    end

    xz_x=reshape(xz_x,1,[]);
    xz_y=reshape(xz_y,1,[]);
    xz_z=reshape(xz_z,1,[]);


    if length(xedgesNoInf)<2
        yz_x=[];
        yz_y=[];
        yz_z=[];
    else
        yz_y=repelem(flip(yedges),4);
        yz_y=yz_y(3:end-2);
        yz_x=reshape(repelem(xedgesNoInf,length(yz_y)),4,[]);
        valuesYZ=values;
        if isInfEdgeX(1)
            valuesYZ(1,:)=[];
        end
        if isInfEdgeX(end)
            valuesYZ(end,:)=[];
        end

        fliporientation=(valuesYZ(1:end-1,end:-1:1)>valuesYZ(2:end,end:-1:1)|...
        isnan(valuesYZ(2:end,end:-1:1))).';
        yz_ytemp=reshape(repmat(yz_y,1,length(xedgesNoInf)-2),4,[]);
        yz_ytemp(:,fliporientation)=flipud(yz_ytemp(:,fliporientation));
        yz_y=reshape([yz_y,reshape(yz_ytemp,1,[]),flip(yz_y)],4,[]);
        yz_z=reshape(transpose([valuesYZ(1,end:-1:1);max(valuesYZ(1:end-1,end:-1:1),...
        valuesYZ(2:end,end:-1:1));valuesYZ(end,:)]),1,[]);
    end

    if nonzerobase
        basevaluesYZ=basevalues;
        if isInfEdgeX(1)
            basevaluesYZ(1,:)=[];
        end
        if isInfEdgeX(end)
            basevaluesYZ(end,:)=[];
        end
        yz_zbase=reshape(transpose([basevaluesYZ(1,end:-1:1);max(basevaluesYZ(1:end-1,end:-1:1),...
        basevaluesYZ(2:end,end:-1:1));basevaluesYZ(end,:)]),1,[]);
    else
        yz_zbase=zeros(1,length(yz_z));
    end
    yz_z=[yz_zbase;yz_z;yz_z;yz_zbase];

    if dropzero

        zzero=~(yz_z(2,:)>0);
        yz_x(:,zzero)=[];
        yz_y(:,zzero)=[];
        yz_z(:,zzero)=[];
    end


    if nonzerobase
        zbase=yz_z(1,:)==yz_z(2,:);
        if~dropzero
            zbase=zbase&(yz_z(2,:)>0);
        end
        yz_x(:,zbase)=[];
        yz_y(:,zbase)=[];
        yz_z(:,zbase)=[];
    end

    yz_x=reshape(yz_x,1,[]);
    yz_y=reshape(yz_y,1,[]);
    yz_z=reshape(yz_z,1,[]);


    xy_x=reshape([xedges(1:end-1);xedges(2:end);xedges(2:end);...
    xedges(1:end-1)],1,[]);
    xy_x=repmat(xy_x,1,countsleny);
    xy_y=repmat([yedges(2:end);yedges(2:end);yedges(1:end-1);...
    yedges(1:end-1)],countslenx,1);
    xy_y=reshape(xy_y,1,[]);
    xy_z=repelem(reshape(values,1,[]),4);

    zzero=~(xy_z>0);
    zzero=repmat(zzero,1,2);


    xy_x=repmat(xy_x,1,2);
    xy_y=[xy_y,reshape(flipud(reshape(xy_y,4,[])),1,[])];
    if nonzerobase
        xy_zbase=repelem(reshape(basevalues,1,[]),4);
    else
        xy_zbase=zeros(size(xy_z));
    end
    xy_z=[xy_z,xy_zbase];

    if dropzero

        xy_x(zzero)=[];
        xy_y(zzero)=[];
        xy_z(zzero)=[];
    end


    if nonzerobase
        zbase=repelem(reshape((values==basevalues)&(values>0),1,[]),4);
        zbase=repmat(zbase,1,2);
        if dropzero
            zbase(zzero)=[];
        end
        xy_x(zbase)=[];
        xy_y(zbase)=[];
        xy_z(zbase)=[];
    end

    x=[xz_x,yz_x,xy_x];
    y=[xz_y,yz_y,xy_y];
    z=[xz_z,yz_z,xy_z];

    isxz=[true(1,length(xz_x)/4),false(1,(length(yz_x)+length(xy_x))/4)];
    isyz=[false(1,length(xz_x)/4),true(1,length(yz_x)/4),false(1,length(xy_x)/4)];

end
