function V=voltage_scattered(obj,omega,dir,Pol)

    obj.SolverStruct.HasSourceChanged=0;

    if~isrow(dir)
        dir=dir.';
    end
    if~isrow(Pol)
        Pol=Pol.';
    end

    numdirections=size(dir,1);

    CenterRho(:,1,:)=obj.SolverStruct.RWG.Center-...
    obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(1,:));
    CenterRho(:,2,:)=obj.SolverStruct.RWG.Center-...
    obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(2,:));
    CenterRho(:,3,:)=obj.SolverStruct.RWG.Center-...
    obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(3,:));

    epsilon0=8.854e-012;
    mu0=1.257e-006;
    c_=1/sqrt(epsilon0*mu0);
    k=omega/c_;

    V=zeros(numdirections,obj.SolverStruct.RWG.EdgesTotal);
    if isfield(obj.MesherStruct.Mesh,'T')&&~isempty(obj.MesherStruct.Mesh.T)
        V=zeros(numdirections,obj.SolverStruct.RWG.EdgesTotal+...
        obj.SolverStruct.strdiel.EdgesTotal);
    end

    for n=1:numdirections
        kv=k*dir(n,:);
        pol=Pol(n,:);
        for m=1:obj.SolverStruct.RWG.EdgesTotal
            TP=obj.SolverStruct.RWG.TrianglePlus(m)+1;
            TM=obj.SolverStruct.RWG.TriangleMinus(m)+1;
            ScalarProduct=sum(kv.*obj.SolverStruct.RWG.Center(:,TP)');
            EmPlus=pol.'*exp(-1i*ScalarProduct);
            ScalarProduct=sum(kv.*obj.SolverStruct.RWG.Center(:,TM)');
            EmMinus=pol.'*exp(-1i*ScalarProduct);
            rhoP=+CenterRho(:,obj.SolverStruct.RWG.VerP(m)+1,TP);
            rhoM=-CenterRho(:,obj.SolverStruct.RWG.VerM(m)+1,TM);
            ScalarPlus=sum(EmPlus.*rhoP);
            ScalarMinus=sum(EmMinus.*rhoM);
            v(m)=obj.SolverStruct.RWG.EdgeLength(m)*...
            (ScalarPlus/2+ScalarMinus/2);
        end
        V(n,1:m)=v;
    end
    if isprop(obj,'SolverType')&&strcmpi(obj.SolverType,'MoM-PO')&&isfield(obj.SolverStruct.RWG,'EdgesTotalMoM')
        V=V(:,1:obj.SolverStruct.RWG.EdgesTotalMoM);
    end
    obj.SolverStruct.Solution.V=V;

end