function[Mesh,Parts]=joinAndVerifyInfiniteGndMesh(obj,pFeed,tFeed,pexciter,texciter)


    [p,t]=em.internal.joinmesh(pFeed,tFeed,pexciter,texciter);


    Ctemp=1/3*(p(:,t(1,:))+p(:,t(2,:))+p(:,t(3,:)));
    [~,index]=sort(-Ctemp(3,:));
    t=t(:,index);


    [pimage,timage]=createImage(obj,p,t);


    [Mesh,Parts]=assembleAndVerifyInfiniteGndMesh(obj,p,t,pimage,timage);

end