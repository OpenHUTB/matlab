function[p_temp,t_temp]=imprintInMesh(pfeedtri,p_temp,t_temp,layerNumber)

    tfeedtri=[1,2,3;1,2,4];
    numPts=size(pfeedtri,1);
    numGroups=numPts/4;
    tfeedtri=repmat(tfeedtri,numGroups,1);
    toffsets=[0:numGroups-1].*4;
    toffsets=repmat(toffsets,2,1);
    toffsets=toffsets(:);
    tfeedtri=tfeedtri+toffsets;
    Mi=em.internal.meshprinting.imprintMesh(pfeedtri,tfeedtri,p_temp{layerNumber}',t_temp{layerNumber}(1:3,:)');
    tdomain=t_temp{layerNumber}(4,1);
    Mi.FeedVertex1=[];
    Mi.FeedVertex2=[];
    p_temp{layerNumber}=Mi.P';
    t_temp{layerNumber}=Mi.t';
    t_temp{layerNumber}(4,:)=tdomain;

end