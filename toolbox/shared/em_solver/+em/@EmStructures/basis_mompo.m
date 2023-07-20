function[metalbasis,basisrad]=basis_mompo(prad,trad,p,t)








    basis=em.solvers.RWGBasis;
    meshIn.P=prad';
    meshIn.t=trad';
    basis.Mesh=meshIn;
    generateBasis(basis);
    basisrad.Area=basis.MetalBasis.AreaF';
    basisrad.Center=basis.MetalBasis.CenterF';
    basisrad.facesize=basis.MetalBasis.Facesize';
    basisrad.Normal=basis.MetalBasis.NormalF';
    basisrad.TrianglePlus=basis.MetalBasis.TriP'-1;
    basisrad.TriangleMinus=basis.MetalBasis.TriM'-1;
    basisrad.VerP=basis.MetalBasis.RelVerP'-1;
    basisrad.VerM=basis.MetalBasis.RelVerM'-1;
    basisrad.Edges=basis.MetalBasis.Edge';




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


    metalbasis.TrianglesTotalMoM=size(trad,2);
    metalbasis.EdgesTotalMoM=size(basisrad.Edges,2);
    metalbasis.TrianglesTotal=size(t,2);
    metalbasis.EdgesTotal=size(metalbasis.Edges,2);






    metalbasis.RWGCenter=basis.MetalBasis.RWGCenter';
    metalbasis.RWGevector=basis.MetalBasis.RWGevector';
    metalbasis.EdgeLength=basis.MetalBasis.EdgeLength';
    metalbasis.RWGNormal=basis.MetalBasis.RWGNormal';
    metalbasis.facesize=basis.MetalBasis.Facesize;























end