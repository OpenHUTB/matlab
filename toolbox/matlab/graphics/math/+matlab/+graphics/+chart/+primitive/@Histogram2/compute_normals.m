function n=compute_normals(values,dropzero)





    xz_n=reshape([repmat(single(-1),size(values,1),1)...
    ,sign((values(:,1:end-1)>values(:,2:end)|isnan(values(:,2:end)))-0.5)...
    ,ones(size(values,1),1,'single')],1,[]);
    if dropzero
        zzeros=~(values>0);
        zzeros=[zzeros(:,1),zzeros(:,1:end-1)&zzeros(:,2:end),zzeros(:,end)];
        xz_n(zzeros)=[];
    end
    xz_n=[zeros(1,length(xz_n),'single');xz_n;...
    zeros(1,length(xz_n),'single')];

    yz_n=reshape(transpose([repmat(single(-1),1,size(values,2));...
    sign((values(1:end-1,:)>values(2:end,:)|isnan(values(2:end,:)))-0.5);...
    ones(1,size(values,2),'single')]),1,[]);
    if dropzero
        zzeros=~(values>0);
        zzeros=[zzeros(1,:);zzeros(1:end-1,:)&zzeros(2:end,:);zzeros(end,:)];
        yz_n(zzeros)=[];
    end
    yz_n=[yz_n;zeros(2,length(yz_n),'single')];

    if dropzero
        nnonzeros=sum(values(:)>0);
        xy_n(3,:)=[ones(1,nnonzeros,'single')...
        ,-ones(1,nnonzeros,'single')];
    else
        xy_n(3,:)=[ones(1,numel(values),'single')...
        ,-ones(1,numel(values),'single')];
    end
    n=[xz_n,yz_n,xy_n];

end