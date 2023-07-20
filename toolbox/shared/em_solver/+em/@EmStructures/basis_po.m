function metalbasis=basis_po(p,t)




    basis=em.solvers.RWGBasis;
    meshIn.P=p';
    meshIn.t=t';
    basis.Mesh=meshIn;
    generateBasis(basis);
    metalbasis.Area=basis.MetalBasis.AreaF';
    metalbasis.Center=basis.MetalBasis.CenterF';
    metalbasis.facesize=basis.MetalBasis.Facesize';
    metalbasis.Normal=basis.MetalBasis.NormalF';
    metalbasis.TrianglePlus=basis.MetalBasis.TriP'-1;
    metalbasis.TriangleMinus=basis.MetalBasis.TriM'-1;
    metalbasis.VerP=basis.MetalBasis.RelVerP'-1;
    metalbasis.VerM=basis.MetalBasis.RelVerM'-1;
    metalbasis.Edges=basis.MetalBasis.Edge';
    metalbasis.TrianglesTotal=size(t,2);
    metalbasis.EdgesTotal=size(metalbasis.Edges,2);


    metalbasis.RWGCenter=basis.MetalBasis.RWGCenter';
    metalbasis.RWGevector=basis.MetalBasis.RWGevector';
    metalbasis.EdgeLength=basis.MetalBasis.EdgeLength';
    metalbasis.RWGNormal=basis.MetalBasis.RWGNormal';
    metalbasis.facesize=basis.MetalBasis.Facesize;









































end