function[t]=SegmentTriangleIntersectionNRay(orig,dir,vert1,vert2,vert3,dist)


















    if nargin==5
        dist=[];
    end

    O=repmat(orig,size(vert1,1),1);
    D=repmat(dir,size(vert1,1),1);


    u=zeros(size(vert1,1),1);
    t=u;


    edge1=vert2-vert1;
    edge2=vert3-vert1;

    tvec=O-vert1;
    pvec=cross(D,edge2,2);
    det=dot(edge1,pvec,2);

    parallel=abs(det)<eps;
    if all(parallel)
        t=inf;
        return;
    end

    det(parallel)=1;
    inv_det=1.0./det;
    u=dot(tvec,pvec,2);
    u=u.*inv_det;


    layer1=(u<0|u>1)|parallel;
    layer1x=(u(~parallel)<0|u(~parallel)>1);
    if all(layer1x)
        return;
    end

    qvec=cross(tvec,edge1,2);
    v=dot(D,qvec,2).*inv_det;
    layer2=(v<0|u+v>1);
    layer2x=(v(~layer1)<0|u(~layer1)+v(~layer1)>1);
    if all(layer2x)
        return;
    end

    layer=(~layer1&~layer2);
    t(layer,:)=dot(edge2(layer,:),qvec(layer,:),2).*inv_det(layer,:);
    if any(t(layer,:)==0)
        t=1;
        return;
    end
    if~isempty(dist)
        t(t<0|t>dist)=0;
    end
    t(parallel)=0;
    t(isnan(t))=0;
end
