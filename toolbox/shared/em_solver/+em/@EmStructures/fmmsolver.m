function fmmsolver(obj,frequency,ElemNumber,Zterm,addtermination,hwait)






    if nargin==5
        hwait=[];
        pwavesource=[];
        D=1;
    end

    if nargin==6
        pwavesource=[];
        D=1;
    end

    if~isfield(obj.SolverStruct,'Solver')
        obj.SolverStruct.Solver=[];
    end

    [calculate_static_soln,calculate_dynamic_soln,calculate_load]...
    =checkcache(obj,frequency,ElemNumber,Zterm,addtermination,Zterm);





    if~isfield(obj.SolverStruct,'hasDielectric')

        obj.SolverStruct.hasDielectric=false;
    end

    if~isfield(obj.MesherStruct.Mesh,'T')
        obj.MesherStruct.Mesh.T=[];
    end


    if~isempty(obj.MesherStruct.Mesh.T)
        obj.SolverStruct.hasDielectric=true;
    else
        obj.SolverStruct.hasDielectric=false;
    end
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

        tf=isMeshSolid(basis);






        if isempty(obj.SolverStruct.Solver)||...
            isa(obj.SolverStruct.Solver,'em.solvers.CFIE')&&~tf||...
            isa(obj.SolverStruct.Solver,'em.solvers.EFIE')&&tf

            if~tf
                c=em.solvers.EFIE;
                addlistener(c,'PreconditionerSize','PostSet',@(src,evt)obj.handleSolverPropEvents(src,evt));
                precondsize=getPreCondSize(obj);
                c.PreconditionerSize=precondsize;
            else
                c=em.solvers.CFIE;
            end
            c.RelativeResidual=1e-4;
            c.Precision=1e-5;
            addlistener(c,'IterativeSolver','PostSet',@(src,evt)obj.handleSolverPropEvents(src,evt));
            addlistener(c,'Iterations','PostSet',@(src,evt)obj.handleSolverPropEvents(src,evt));
            addlistener(c,'RelativeResidual','PostSet',@(src,evt)obj.handleSolverPropEvents(src,evt));
            addlistener(c,'Precision','PostSet',@(src,evt)obj.handleSolverPropEvents(src,evt));
        else
            c=obj.SolverStruct.Solver;
        end
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






        if isprop(obj,'FeedLocation')

            feededge=em.EmStructures.getFeedEdges(obj,p,metalbasis);
            if isa(obj,'rfpcb.PrintedLine')
                objclass='rfpcb.PrintedLine';
            else
                objclass=class(obj);
            end
            metalbasis=em.EmStructures.alignfeedcurrents(metalbasis,...
            t,feededge,objclass);
        else
            feededge=[];
        end




        if TetrahedraTotal>0
            error('No tets for you !!');
        end



        obj.MesherStruct.Mesh.numEdges=c.Geom.EdgesTotal;
        obj.SolverStruct.Solver=c;
        obj.SolverStruct.RWG=metalbasis;
        obj.SolverStruct.RWG.EdgeLength=c.Geom.EdgeLength';
        obj.SolverStruct.RWG.TrianglesTotal=c.Geom.FacesTotal;
        obj.SolverStruct.RWG.EdgesTotal=c.Geom.EdgesTotal;
        obj.SolverStruct.RWG.selfint.IS=c.Geom.IS';
        obj.SolverStruct.RWG.feededge=feededge;
        resetHasMeshChanged(obj);
        obj.MesherStruct.HasTaperChanged=0;
        setHasSolverChanged(obj,false);
        setHasSolverTypeChanged(obj,false);
    end
    if calculate_dynamic_soln&&D
        c=obj.SolverStruct.Solver;
        omega=2*pi*frequency;



        if~isempty(obj.SolverStruct.Source)&&strcmp(obj.SolverStruct.Source.type,'planewave')
            obj.SolverStruct.HasSourceChanged=0;
            dir=obj.Direction./norm(obj.Direction);
            Pol=obj.Polarization;
            solvePlaneWave(c,frequency,dir.',Pol.');
            obj.SolverStruct.Solution.V=c.V_efie;
            I=c.IBasis;
        else
            V=voltagevectorfmm(obj,ElemNumber,omega,pwavesource);

            [ZL,loadedge]=loadingedge(obj,calculate_load,frequency,Zterm,...
            addtermination,hwait);



            for n=1:size(V,2)






                fe_indx=find(V(:,n));
                V(fe_indx,n)=1./V(fe_indx,n);
                solveDrivenVoltage(c,frequency,V(:,n));
                I(:,n)=c.IBasis;
            end
        end

        savesolution(obj,I,frequency,addtermination,ElemNumber);
    end

end