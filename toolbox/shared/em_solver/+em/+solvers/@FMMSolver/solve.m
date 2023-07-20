function solve(obj,type)



    if strcmpi(obj.IEType,'EFIE')
        generateBFNeighbors(obj);
    end
    if strcmpi(type,'PlaneWave')
        expandIncidentField(obj);
    end
    generatePreconditioner(obj);
    generateRHS(obj);
    MATVEC=@(I)generateLHS(obj,I);
    b=obj.RHS;
    relres=obj.RelativeResidual;
    numiters=obj.Iterations;

    if size(b,1)<numiters
        numiters=size(b,1);
    end
    switch obj.IterativeSolver
    case 'gmres'
        [Icfie,flag,rres,its,resvec]=gmres(MATVEC,b,[],relres,numiters,[],[],b);
    case 'bicgstab'
        [Icfie,flag,rres,its,resvec]=bicgstab(MATVEC,b,relres,numiters,[],[],b);
    case 'cgs'
        [Icfie,flag,rres,its,resvec]=cgs(MATVEC,b,relres,numiters,[],[],b);
    case 'tfqmr'
        [Icfie,flag,rres,its,resvec]=tfqmr(MATVEC,b,relres,numiters,[],[],b);
    end

    obj.IBasis=Icfie;
    obj.I=currentOnPatches(obj);
    obj.ResidualVector=resvec/resvec(1);










end

