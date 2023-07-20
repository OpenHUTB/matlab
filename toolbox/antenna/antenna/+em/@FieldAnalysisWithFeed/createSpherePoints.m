function p=createSpherePoints(obj,N)

    R=em.internal.findRadiusOfBoundingSphere(obj.MesherStruct.Mesh.p);

    [x,y,z]=sphere(N);
    p=R*[x(:)';y(:)';z(:)'];
