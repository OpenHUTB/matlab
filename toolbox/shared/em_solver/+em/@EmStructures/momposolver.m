function momposolver(obj,frequency,ElemNumber,Zterm,addtermination,hwait,pwavesource)
















    if nargin<=6
        pwavesource=[];
    end

    [calculate_static_soln,calculate_dynamic_soln,calculate_load]...
    =checkcache(obj,frequency,ElemNumber,Zterm,addtermination,Zterm);

    if calculate_static_soln

        obj.SolverStruct.hasDielectric=false;
        obj.MesherStruct.Mesh.T=[];

        p=obj.MesherStruct.Mesh.p;
        t=obj.MesherStruct.Mesh.t;


        idPO=t(4,:)>=100;
        prad=p;
        trad=t(:,~idPO);
        tPO=t(:,idPO);
        t=[trad,tPO];


        idPO=t(4,:)>=100;

        obj.MesherStruct.Mesh.p=p;
        obj.MesherStruct.Mesh.t=t;
        obj.MesherStruct.Mesh.prad=prad;
        obj.MesherStruct.Mesh.trad=trad;

        [metalbasis,metalbasisrad]=em.EmStructures.basis_mompo(prad,...
        trad,p,t);


        if isprop(obj,'FeedLocation')
            feededge=em.EmStructures.getFeedEdges(obj,p,metalbasisrad);
            rtloc=obj.FeedLocation';
        else
            feededge=em.EmStructures.feeding_edge(p,metalbasisrad.Edges,...
            obj.Element.FeedLocation,obj.MesherStruct.Mesh.FeedType,obj.Element);
            rtloc=obj.Element.FeedLocation';
        end



        mode='location';
        metalbasis=em.EmStructures.findLitRegionsEm(metalbasis,p,t,idPO,rtloc,mode);


        [coeff,weights]=em.EmStructures.gausstri(7,5);
        selfint=em.EmStructures.calc_integral_c(prad,trad(1:3,:),...
        metalbasisrad.Center,metalbasisrad.Area,metalbasisrad.Normal,...
        metalbasisrad.facesize,coeff,weights,2);



        obj.MesherStruct.Mesh.numEdges=metalbasis.EdgesTotal;
        obj.MesherStruct.Mesh.numPOEdges=metalbasis.EdgesTotal-...
        size(metalbasisrad.Edges,2);
        obj.SolverStruct.RWG=metalbasis;
        obj.SolverStruct.RWG.feededge=feededge;
        obj.SolverStruct.selfint=selfint;
        resetHasMeshChanged(obj);
        obj.MesherStruct.HasTaperChanged=0;
        setHasSolverChanged(obj,false);
        setHasSolverTypeChanged(obj,false)
    end

    if calculate_dynamic_soln

        CenterRho(:,1,:)=obj.SolverStruct.RWG.Center-...
        obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(1,:));
        CenterRho(:,2,:)=obj.SolverStruct.RWG.Center-...
        obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(2,:));
        CenterRho(:,3,:)=obj.SolverStruct.RWG.Center-...
        obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(3,:));

        [coeff,WM]=em.EmStructures.gausstri(3,2);

        omega=2*pi*frequency;


        V=voltagemompo(obj,ElemNumber,omega,pwavesource);


        [ZL,loadedge]=loadingedge(obj,calculate_load,frequency,...
        Zterm,addtermination,hwait);


        if all(loadedge>obj.SolverStruct.RWG.EdgesTotalMoM)
            loadedge=0;
        else
            idx=find(loadedge>obj.SolverStruct.RWG.EdgesTotalMoM);
            loadedge(idx)=[];
            ZL(idx)=[];
        end

        Vertexes=zeros(3,3,obj.SolverStruct.RWG.TrianglesTotal);
        for m=1:obj.SolverStruct.RWG.TrianglesTotalMoM
            Vertexes(:,:,m)=obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(1:3,m));
        end


        [Ir,Ii]=em.EmStructures.zmm_po_c(obj.SolverStruct.RWG,...
        obj.SolverStruct.selfint,CenterRho,coeff,Vertexes,WM,...
        omega,0.0,real(V),imag(V),loadedge,real(ZL),imag(ZL));
        I=complex(Ir,Ii);



        savemomposolution(obj,I,frequency,addtermination,ElemNumber);
    end

end
