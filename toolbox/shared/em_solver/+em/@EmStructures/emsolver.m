function I=emsolver(obj,V,ZL,loadedge,omega)





    if isfield(obj.MesherStruct,'thickness')
        metalthickness=obj.MesherStruct.thickness;
        conductivity=obj.MesherStruct.conductivity;
    else
        metalthickness=0;
        conductivity=inf;
    end
    Zsurf=em.EmStructures.Zsurf_calc(omega,metalthickness,conductivity);
    CenterRho(:,1,:)=obj.SolverStruct.RWG.Center-...
    obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(1,:));
    CenterRho(:,2,:)=obj.SolverStruct.RWG.Center-...
    obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(2,:));
    CenterRho(:,3,:)=obj.SolverStruct.RWG.Center-...
    obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(3,:));
    [coeffM,WM,OrderM]=em.EmStructures.gausstri(3,2);

    if obj.SolverStruct.hasDielectric
        PointsM=zeros(3,OrderM,obj.SolverStruct.RWG.TrianglesTotal);
        PointsMRho=zeros(3,OrderM,3,obj.SolverStruct.RWG.TrianglesTotal);
        G=zeros(3,OrderM);
        for m=1:obj.SolverStruct.RWG.TrianglesTotal
            Vertexes=obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(1:3,m));
            for n=1:OrderM
                G(:,n)=coeffM(1,n)*Vertexes(:,1)+coeffM(2,n)*Vertexes(:,2)...
                +coeffM(3,n)*Vertexes(:,3);
            end
            PointsM(:,:,m)=G;
            PointsMRho(:,:,1,m)=G-repmat(obj.MesherStruct.Mesh.p...
            (:,obj.MesherStruct.Mesh.t(1,m)),[1,OrderM]);
            PointsMRho(:,:,2,m)=G-repmat(obj.MesherStruct.Mesh.p...
            (:,obj.MesherStruct.Mesh.t(2,m)),[1,OrderM]);
            PointsMRho(:,:,3,m)=G-repmat(obj.MesherStruct.Mesh.p...
            (:,obj.MesherStruct.Mesh.t(3,m)),[1,OrderM]);
        end

        [coeffS,weightsS,IndexS]=em.EmStructures.gausstri(3,2);
        obj.SolverStruct.strdiel.IndexF=IndexS;
        obj.SolverStruct.strdiel.WF=weightsS';
        obj.SolverStruct.strdiel.PointsF=zeros(3,IndexS,...
        obj.SolverStruct.strdiel.FacesNontrivial);
        G=zeros(3,IndexS);
        for m=1:obj.SolverStruct.strdiel.FacesNontrivial
            Vertexes=obj.SolverStruct.strdiel.P(:,...
            obj.SolverStruct.strdiel.Faces(:,m));
            for n=1:IndexS
                G(:,n)=coeffS(1,n)*Vertexes(:,1)+...
                coeffS(2,n)*Vertexes(:,2)+...
                coeffS(3,n)*Vertexes(:,3);
            end
            obj.SolverStruct.strdiel.PointsF(:,:,m)=G;
        end

        [coeffT,weightsT,IndexT]=em.EmStructures.gausstet(1,1);
        obj.SolverStruct.strdiel.IndexT=IndexT;
        obj.SolverStruct.strdiel.WT=weightsT';
        obj.SolverStruct.strdiel.PointsT=zeros(3,IndexT,...
        size(obj.MesherStruct.Mesh.T,2));
        G=zeros(3,IndexT);
        for m=1:size(obj.MesherStruct.Mesh.T,2)
            Vertexes=obj.SolverStruct.strdiel.P(:,...
            obj.MesherStruct.Mesh.T(:,m));
            for n=1:IndexT
                G(:,n)=coeffT(1,n)*Vertexes(:,1)+...
                coeffT(2,n)*Vertexes(:,2)+...
                coeffT(3,n)*Vertexes(:,3)+...
                coeffT(4,n)*Vertexes(:,4);
            end
            obj.SolverStruct.strdiel.PointsT(:,:,m)=G;
        end
    else
        Vertexes=zeros(3,3,obj.SolverStruct.RWG.TrianglesTotal);
        for m=1:obj.SolverStruct.RWG.TrianglesTotal
            Vertexes(:,:,m)=obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(1:3,m));
        end
    end




    if strcmpi(class(obj),'infiniteArray')
        if obj.MesherStruct.infGPconnected
            NumJoints=1;
        else
            NumJoints=0;
        end
        if strcmpi(class(obj.Element),'helix')||...
            strcmpi(class(obj.Element),'monocone')
            L=obj.Element.GroundPlaneRadius;
            W=L;
        else
            L=obj.Element.GroundPlaneLength;
            W=obj.Element.GroundPlaneWidth;
        end
        MySize=(obj.SolverStruct.RWG.EdgesTotal-NumJoints)/2;
        [Ir,Ii]=em.EmStructures.zmm_infarray_c(obj.SolverStruct.RWG.Center,...
        obj.SolverStruct.RWG.TrianglePlus,...
        obj.SolverStruct.RWG.TriangleMinus,CenterRho,...
        obj.SolverStruct.RWG.VerP,obj.SolverStruct.RWG.VerM,...
        obj.SolverStruct.RWG.EdgeLength,coeffM,...
        Vertexes,OrderM,WM,obj.SolverStruct.RWG.selfint.IS,...
        obj.SolverStruct.RWG.selfint.JS,...
        obj.SolverStruct.RWG.selfint.SS,...
        obj.SolverStruct.RWG.selfint.RS,omega,0.0,...
        real(V(1:MySize+NumJoints,:)),imag(V(1:MySize+NumJoints,:))...
        ,W,L,pi/180*(obj.ScanAzimuth),pi/180*(90-obj.ScanElevation),...
        obj.SolverStruct.sumterms,NumJoints);
        I=complex(Ir,Ii);
        I(MySize+NumJoints+1:2*MySize+NumJoints)=-I(1:MySize);
    elseif isprop(obj,'Element')&&strcmpi(class(obj.Element),'infiniteArray')
        if obj.Element.MesherStruct.infGPconnected
            NumJoints=1;
        else
            NumJoints=0;
        end
        if strcmpi(class(obj.Element.Element),'helix')||...
            strcmpi(class(obj.Element.Element),'monocone')
            L=obj.Element.Element.GroundPlaneRadius;
            W=L;
        else
            L=obj.Element.Element.GroundPlaneLength;
            W=obj.Element.Element.GroundPlaneWidth;
        end
        MySize=(obj.SolverStruct.RWG.EdgesTotal-NumJoints)/2;
        [Ir,Ii]=em.EmStructures.zmm_infarray_c(obj.SolverStruct.RWG.Center,...
        obj.SolverStruct.RWG.TrianglePlus,...
        obj.SolverStruct.RWG.TriangleMinus,CenterRho,...
        obj.SolverStruct.RWG.VerP,obj.SolverStruct.RWG.VerM,...
        obj.SolverStruct.RWG.EdgeLength,coeffM,...
        Vertexes,OrderM,WM,obj.SolverStruct.RWG.selfint.IS,...
        obj.SolverStruct.RWG.selfint.JS,...
        obj.SolverStruct.RWG.selfint.SS,...
        obj.SolverStruct.RWG.selfint.RS,omega,0.0,...
        real(V(1:MySize+NumJoints,:)),imag(V(1:MySize+NumJoints,:))...
        ,W,L,pi/180*(obj.Element.ScanAzimuth),pi/180*(90-obj.Element.ScanElevation),...
        obj.Element.SolverStruct.sumterms,NumJoints);
        I=complex(Ir,Ii);
        I(MySize+NumJoints+1:2*MySize+NumJoints)=-I(1:MySize);
    elseif obj.MesherStruct.infGP&&~obj.SolverStruct.hasDielectric
        if obj.MesherStruct.infGPconnected
            if strcmpi(class(obj),'planeWaveExcitation')
                NumJoints=size(obj.Element.FeedLocation,1);
            else
                NumJoints=size(obj.FeedLocation,1);
            end
            if strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge')
                NumJoints=0;
            end
            if NumJoints==1
                MySize=(obj.SolverStruct.RWG.EdgesTotal-NumJoints)/2;
                [Ir,Ii]=em.EmStructures.zmm_igp_conn_c(obj.SolverStruct.RWG.Center,...
                obj.SolverStruct.RWG.TrianglePlus,...
                obj.SolverStruct.RWG.TriangleMinus,CenterRho,...
                obj.SolverStruct.RWG.VerP,obj.SolverStruct.RWG.VerM,...
                obj.SolverStruct.RWG.EdgeLength,coeffM,...
                Vertexes,OrderM,WM,obj.SolverStruct.RWG.selfint.IS,...
                obj.SolverStruct.RWG.selfint.JS,...
                obj.SolverStruct.RWG.selfint.SS,...
                obj.SolverStruct.RWG.selfint.RS,omega,0.0,...
                real(V(1:MySize+NumJoints,:)),imag(V(1:MySize+NumJoints,:)),...
                loadedge,real(ZL),imag(ZL),NumJoints);
                I=complex(Ir,Ii);
                I(MySize+NumJoints+1:2*MySize+NumJoints)=-I(1:MySize);
            else
                [Ir,Ii]=em.EmStructures.zmm_solve_metal_c(obj.SolverStruct.RWG,...
                obj.SolverStruct.RWG.selfint,CenterRho,coeffM,...
                Vertexes,WM,omega,0.0,real(V),imag(V),...
                loadedge,real(ZL),imag(ZL));
                I=complex(Ir,Ii);
            end
        else
            [Ir,Ii]=em.EmStructures.zmm_igp_bal_c(obj.SolverStruct.RWG.Center,...
            obj.SolverStruct.RWG.TrianglePlus,...
            obj.SolverStruct.RWG.TriangleMinus,CenterRho,...
            obj.SolverStruct.RWG.VerP,obj.SolverStruct.RWG.VerM,...
            obj.SolverStruct.RWG.EdgeLength,coeffM,...
            Vertexes,OrderM,WM,obj.SolverStruct.RWG.selfint.IS,...
            obj.SolverStruct.RWG.selfint.JS,...
            obj.SolverStruct.RWG.selfint.SS,...
            obj.SolverStruct.RWG.selfint.RS,omega,0.0,...
            real(V(1:obj.SolverStruct.RWG.EdgesTotal/2,:)),...
            imag(V(1:obj.SolverStruct.RWG.EdgesTotal/2,:)),loadedge,...
            real(ZL),imag(ZL),obj.SolverStruct.RWG.selfint.selfneighbors);
            I=complex(Ir,Ii);
            I(obj.SolverStruct.RWG.EdgesTotal/2+1:...
            obj.SolverStruct.RWG.EdgesTotal,:)=-I;
        end
    else
        if obj.SolverStruct.hasDielectric
            if isinf(conductivity)

                [Ir,Ii]=em.EmStructures.zmetal_diel_solve_c(obj.SolverStruct.RWG,...
                obj.SolverStruct.RWG.selfint,CenterRho,PointsM,PointsMRho,...
                WM,omega,0.0,real(V),imag(V),loadedge,...
                real(ZL),imag(ZL),obj.SolverStruct.strdiel,...
                obj.SolverStruct.strdiel.selfintdiel,...
                obj.SolverStruct.strdiel.selfintmetaldiel,...
                obj.SolverStruct.const);
                I=complex(Ir,Ii);

            else
                [Ir,Ii]=em.EmStructures.zmetal_diel_solve_c_cond(obj.SolverStruct.RWG,...
                obj.SolverStruct.RWG.selfint,CenterRho,PointsM,PointsMRho,...
                WM,omega,0.0,real(V),imag(V),loadedge,...
                real(ZL),imag(ZL),obj.SolverStruct.strdiel,...
                obj.SolverStruct.strdiel.selfintdiel,...
                obj.SolverStruct.strdiel.selfintmetaldiel,...
                obj.SolverStruct.const,real(Zsurf),imag(Zsurf));
                I=complex(Ir,Ii);
            end

        else
            if isinf(conductivity)
                [Ir,Ii]=em.EmStructures.zmm_solve_metal_c(obj.SolverStruct.RWG,...
                obj.SolverStruct.RWG.selfint,CenterRho,coeffM,...
                Vertexes,WM,omega,0.0,real(V),imag(V),...
                loadedge,real(ZL),imag(ZL));
                I=complex(Ir,Ii);
            else
                [Ir,Ii]=em.EmStructures.zmm_solve_metal_c_cond(obj.SolverStruct.RWG,...
                obj.SolverStruct.RWG.selfint,CenterRho,coeffM,...
                Vertexes,WM,omega,0.0,real(V),imag(V),...
                loadedge,real(ZL),imag(ZL),real(Zsurf),imag(Zsurf));
                I=complex(Ir,Ii);

            end
        end
    end
end
