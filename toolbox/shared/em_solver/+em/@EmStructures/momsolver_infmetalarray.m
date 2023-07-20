function momsolver_infmetalarray(obj,frequency,ElemNumber,Zterm,addtermination,hwait,pwavesource,...
    D,calculate_static_soln,calculate_dynamic_soln,calculate_load)








    if~isfield(obj.MesherStruct.Mesh,'T')
        obj.MesherStruct.Mesh.T=[];
    end
    obj.SolverStruct.hasDielectric=false;


    if calculate_static_soln
        p=obj.MesherStruct.Mesh.p;
        t=obj.MesherStruct.Mesh.t;
        TrianglesTotal=length(t);
        T=obj.MesherStruct.Mesh.T;
        TetrahedraTotal=length(T);
        meshIn.P=p';
        meshIn.t=t';

        basis=em.solvers.RWGBasis;
        basis.Mesh=meshIn;
        generateBasis(basis);
        c.Mesh=meshIn;
        c.Geom=basis.MetalBasis;
        metalbasis.Area=c.Geom.AreaF';
        metalbasis.Center=c.Geom.CenterF';
        metalbasis.facesize=c.Geom.Facesize;
        metalbasis.Normal=c.Geom.NormalF';
        metalbasis.TrianglePlus=c.Geom.TriP'-1;
        metalbasis.TriangleMinus=c.Geom.TriM'-1;
        metalbasis.VerP=c.Geom.RelVerP'-1;
        metalbasis.VerM=c.Geom.RelVerM'-1;
        metalbasis.Edges=c.Geom.Edge';
        metalbasis.FCRhoP=c.Geom.FCRhoP';
        metalbasis.FCRhoM=c.Geom.FCRhoM';

        obj.MesherStruct.Mesh.numEdges=c.Geom.EdgesTotal;
        obj.SolverStruct.Solver=c;
        obj.SolverStruct.RWG=metalbasis;
        obj.SolverStruct.RWG.EdgeLength=c.Geom.EdgeLength';
        obj.SolverStruct.RWG.TrianglesTotal=c.Geom.FacesTotal;
        obj.SolverStruct.RWG.EdgesTotal=c.Geom.EdgesTotal;
        obj.SolverStruct.RWG.selfint.IS=c.Geom.IS';
        resetHasMeshChanged(obj);
        obj.MesherStruct.HasTaperChanged=0;
        setHasSolverChanged(obj,false);
        setHasSolverTypeChanged(obj,false);


        const.epsilon=8.85418782e-012;
        const.mu=1.25663706e-006;
        const.c=1/sqrt(const.epsilon*const.mu);
        const.eta=sqrt(const.mu/const.epsilon);
        geom=c.Geom;


        if isprop(obj,'FeedLocation')
            feed=obj.Element.FeedLocation;
            feed(3)=max(p(:,3));
            dist=geom.DipoleCenter-repmat(feed,geom.EdgesTotal,1);
            dist=sqrt(dot(dist,dist,2));
            [~,feededge]=min(dist);
        else
            feededge=[];
        end




        resetHasMeshChanged(obj);
        obj.SolverStruct.RWG.feededge=feededge;
        obj.MesherStruct.geom=geom;
        obj.MesherStruct.const=const;
    end

    if calculate_dynamic_soln&&D
        omega=2*pi*frequency;


        if strcmp(obj.SolverStruct.Source.type,'planewave')
            V=voltagevector(obj,ElemNumber,omega,pwavesource);
        else
            obj.SolverStruct.HasSourceChanged=0;
            V=zeros(obj.MesherStruct.geom.EdgesTotal,1);
            feededge=obj.SolverStruct.RWG.feededge;
            V(feededge)=+1./obj.MesherStruct.geom.EdgeLength(feededge);
        end


        pz=obj.MesherStruct.Mesh.p(3,:);
        pzmax=max(pz);

        I=solvercallmetalinfarray(obj,V,omega,pz,pzmax);


        if anynan(I)||any(isinf(I),"all")
            error(message('antenna:antennaerrors:InvalidAnswer'));
        end

        if strcmpi(class(obj.Element),'infiniteArray')
            if~isempty(obj.SolverStruct.Solution.ScanElevation)&&...
                ((obj.SolverStruct.Solution.ScanElevation==obj.Element.ScanElevation)&&...
                (obj.SolverStruct.Solution.ScanAzimuth==obj.Element.ScanAzimuth))
                obj.SolverStruct.Solution.Sfrequency=...
                [obj.SolverStruct.Solution.Frequency,frequency];
                obj.SolverStruct.Solution.SI=...
                [obj.SolverStruct.Solution.I,1i*2*pi*frequency*I];
            else
                obj.SolverStruct.Solution.SI=1i*2*pi*frequency*I;
                obj.SolverStruct.Solution.Sfrequency=frequency;
            end
            obj.SolverStruct.Solution.ScanElevation=obj.Element.ScanElevation;
            obj.SolverStruct.Solution.ScanAzimuth=obj.Element.ScanAzimuth;
        else
            if~isempty(obj.SolverStruct.Solution.ScanElevation)&&...
                ((obj.SolverStruct.Solution.ScanElevation==obj.ScanElevation)&&...
                (obj.SolverStruct.Solution.ScanAzimuth==obj.ScanAzimuth))
                obj.SolverStruct.Solution.Frequency=...
                [obj.SolverStruct.Solution.Frequency,frequency];
                obj.SolverStruct.Solution.I=...
                [obj.SolverStruct.Solution.I,1i*2*pi*frequency*I];
            else
                obj.SolverStruct.Solution.I=1i*2*pi*frequency*I;
                obj.SolverStruct.Solution.Frequency=frequency;
            end
            obj.SolverStruct.Solution.ScanElevation=obj.ScanElevation;
            obj.SolverStruct.Solution.ScanAzimuth=obj.ScanAzimuth;
        end

    end
end

function[I]=solvercallmetalinfarray(obj,V,omega,pz,pzmax)
    if any(pz~=pzmax)

        I=solver_infmetalarrayDirect(obj,V,omega);
    else

        I=solver_infmetalarrayPoisson(obj,V,omega);
    end
end
