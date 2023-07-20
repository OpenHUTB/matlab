function momsolver(obj,frequency,ElemNumber,Zterm,addtermination,hwait,pwavesource,D)























    if nargin==5
        hwait=[];
        pwavesource=[];
        D=1;
    end

    if nargin==6
        pwavesource=[];
        D=1;
    end

    [calculate_static_soln,calculate_dynamic_soln,calculate_load]...
    =checkcache(obj,frequency,ElemNumber,Zterm,addtermination,Zterm);
    if strcmpi(class(obj),'infiniteArray')&&obj.Substrate.EpsilonR>1
        momsolver_infdielarray(obj,frequency,ElemNumber,Zterm,addtermination,hwait,pwavesource,D,...
        calculate_static_soln,calculate_dynamic_soln,calculate_load);
    elseif strcmpi(class(obj),'planeWaveExcitation')&&strcmpi(class(obj.Element),'infiniteArray')...
        &&obj.Element.Substrate.EpsilonR>1
        momsolver_infdielarray(obj,frequency,ElemNumber,Zterm,addtermination,hwait,pwavesource,D,...
        calculate_static_soln,calculate_dynamic_soln,calculate_load);
    elseif strcmpi(class(obj),'infiniteArray')&&obj.RemoveGround==1
        momsolver_infmetalarray(obj,frequency,ElemNumber,Zterm,addtermination,hwait,pwavesource,D,...
        calculate_static_soln,calculate_dynamic_soln,calculate_load);
    elseif strcmpi(class(obj),'planeWaveExcitation')&&strcmpi(class(obj.Element),'infiniteArray')&&obj.Element.RemoveGround==1
        momsolver_infmetalarray(obj,frequency,ElemNumber,Zterm,addtermination,hwait,pwavesource,D,...
        calculate_static_soln,calculate_dynamic_soln,calculate_load);
    else




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


            nb=1;
            if~nb

                metalbasis=em.EmStructures.basis_metal_c(p,t(1:3,:));
            else

                basis=em.solvers.RWGBasis;
                meshIn.P=p';
                meshIn.t=t';
                basis.Mesh=meshIn;
                generateBasis(basis);
                metalbasis.Area=basis.MetalBasis.AreaF';
                metalbasis.Center=basis.MetalBasis.CenterF';
                metalbasis.facesize=basis.MetalBasis.Facesize;
                metalbasis.Normal=basis.MetalBasis.NormalF';
                metalbasis.TrianglePlus=basis.MetalBasis.TriP'-1;
                metalbasis.TriangleMinus=basis.MetalBasis.TriM'-1;
                metalbasis.VerP=basis.MetalBasis.RelVerP-1;
                metalbasis.VerM=basis.MetalBasis.RelVerM-1;
                metalbasis.Edges=basis.MetalBasis.Edge';
            end

            if isa(obj,'pcbStack')
                s=settings;
                useNewMesherForPcbStack=s.antenna.Mesher.UsePCBStackR2021bEngine.ActiveValue;
            else
                useNewMesherForPcbStack=0;
            end

            if(isa(obj,'rfpcb.PrintedLine')||isa(obj,'pcbComponent'))||useNewMesherForPcbStack

                metalbasis=overrideFeedEdgeBasis(obj,metalbasis,p,t);
            elseif isa(obj,'AntennaWithAFeedGapThatNeedsBasisFunctions')
                metalbasis=constructFeedGapBasis(obj,metalbasis,p,t);
            end



            if obj.MesherStruct.infGP&&obj.MesherStruct.infGPconnected&&...
                (TetrahedraTotal==0)&&~strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge')
                if strcmpi(class(obj),'planeWaveExcitation')
                    NumJoints=size(obj.Element.FeedLocation,1);
                else
                    NumJoints=size(obj.FeedLocation,1);
                end
                metalbasis=em.EmStructures.create_fedding_edge(p,t,...
                metalbasis,TrianglesTotal,NumJoints,0);
            end

            if~nb


                metalbasis=em.EmStructures.retain_independent_basis(t,metalbasis);
            end

            EdgesTotal=length(metalbasis.Edges);
            metalbasis.EdgeLength=zeros(1,EdgesTotal);
            for m=1:EdgesTotal
                metalbasis.EdgeLength(m)=norm(p(:,metalbasis.Edges(1,m))-p(:,metalbasis.Edges(2,m)));
            end


            if isprop(obj,'FeedLocation')

                feededge=em.EmStructures.getFeedEdges(obj,p,metalbasis);
                if isa(obj,'rfpcb.PrintedLine')
                    objclass='rfpcb.PrintedLine';
                elseif isa(obj,'em.PrintedAntenna')
                    objclass='em.PrintedAntenna';
                else
                    objclass=class(obj);
                end
                metalbasis=em.EmStructures.alignfeedcurrents(metalbasis,...
                t,feededge,objclass);
            else
                feededge=[];
            end


            if 0
                plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
                figure;

                plot_triCenters=transpose(metalbasis.Center);
                plot_P=meshIn.P;
                plot_t=meshIn.t;
                plot_edges=transpose(metalbasis.Edges);
                plot_edgeCenters=(plot_P(plot_edges(:,1),:)+plot_P(plot_edges(:,2),:))/2;
                plot_feedLocations=plot_edgeCenters(feededge,:);
                plot_nominalFeedLocations=obj.FeedLocation;
                plot_feedTriIndicesP=transpose(metalbasis.TrianglePlus(:,feededge))+1;
                plot_feedTriIndicesM=transpose(metalbasis.TriangleMinus(:,feededge))+1;


                temp=plot_triCenters(:,3)>1e-5;
                p1=patch('vertices',plot_P,'faces',plot_t(temp,1:3));hold on;
                p1.FaceColor=[1,1,1];
                p1.EdgeColor='k';
                p1.FaceAlpha=1.0;
                p2=patch('vertices',plot_P,'faces',plot_t(~temp,1:3));
                p2.FaceColor=double([0xB0,0xC4,0xDE])/255.0;
                p2.EdgeColor='k';
                p2.FaceAlpha=1.0;


                for m=1:size(plot_feedLocations,1)
                    plot3(plot_feedLocations(m,1),plot_feedLocations(m,2),plot_feedLocations(m,3),'*g','MarkerSize',12);

                end


                for m=1:size(plot_nominalFeedLocations,1)
                    plot3(plot_nominalFeedLocations(m,1),plot_nominalFeedLocations(m,2),plot_nominalFeedLocations(m,3),'or','MarkerSize',20);
                end


                colors=repmat([1,0,0;0.5,1,0;0,0,1],30,1);
                colors=prism(size(plot_feedTriIndicesP,1));
                for m=1:size(plot_feedTriIndicesP,1)
                    patch('vertices',plot_P,'faces',plot_t(plot_feedTriIndicesP(m),1:3),'FaceColor',colors(m,:),'EdgeColor','k','FaceAlpha',0.5);
                    patch('vertices',plot_P,'faces',plot_t(plot_feedTriIndicesM(m),1:3),'FaceColor',colors(m,:),'EdgeColor','k','FaceAlpha',0.5);






                end


                view(88,90);xlabel('x, m');ylabel('y, m');zlabel('z, m');
                axis equal;axis tight;set(gcf,'Color','White');
            end


            selfint=metalselfint(obj,p,t,metalbasis,TetrahedraTotal);

            if TetrahedraTotal>0


                const.epsilon=8.85418782e-012;
                const.mu=1.25663706e-006;
                const.c=1/sqrt(const.epsilon*const.mu);
                const.eta=sqrt(const.mu/const.epsilon);
                const.Epsilon_r=const.epsilon*obj.MesherStruct.Mesh.Eps_r;
                const.tan_delta=obj.MesherStruct.Mesh.tan_delta;


                diel=em.EmStructures.volumemesh(p,T,const);


                aa=metalbasis.Edges';
                Index1=find(ismember(diel.Edges',metalbasis.Edges','rows'));
                Index2=find(ismember(diel.Edges',[aa(:,2),aa(:,1)],'rows'));
                Index=unique([Index1;Index2]);
                temp=setdiff(1:size(diel.Edges,2),Index);
                diel.Edges=[diel.Edges(:,Index),diel.Edges(:,temp)];


                facesboundary=diel.Faces(:,1:diel.FacesNontrivial);
                strdiel=em.EmStructures.basis_dielectric_c(p,diel.T,...
                facesboundary,diel.Edges,diel.AT,const);

                strdiel.FacesNontrivial=diel.FacesNontrivial;
                strdiel.Faces=diel.Faces;
                strdiel.P=p;
                strdiel.T=diel.T;
                strdiel.EdgesTotal=size(strdiel.Edge,2);
                strdiel.BasisTC=reshape(strdiel.BasisTC,[3,6,size(T,2)]);
                strdiel.BasisTCn=strdiel.BasisTC;


                [coeffS,weightsS]=em.EmStructures.gausstri(3,2);

                [coeffT,weightsT]=em.EmStructures.gausstet(1,1);


                facesboundary=strdiel.Faces(:,1:strdiel.FacesNontrivial);

                intdiel=em.EmStructures.calc_integral_diel_c(strdiel.P,strdiel.T,...
                facesboundary,strdiel.CenterF,strdiel.AreaF,...
                strdiel.Facesize,strdiel.CenterT,strdiel.VolumeT,...
                strdiel.Tetsize,coeffS,weightsS,5,coeffT,weightsT,1e-3);

                intmetaldiel=em.EmStructures.calc_integral_metal_diel_c(strdiel.P,strdiel.T,...
                facesboundary,t(1:3,:),strdiel.CenterF,strdiel.AreaF,...
                strdiel.Facesize,strdiel.CenterT,strdiel.VolumeT,...
                strdiel.Tetsize,metalbasis.Center,metalbasis.Area,...
                metalbasis.facesize,coeffS,weightsS,5,coeffT,weightsT,1e-3);

                strdiel=em.EmStructures.embedded_basis(strdiel,t(1:3,:),...
                diel.AT,diel.FacesNontrivial,const);

                obj.SolverStruct.strdiel=strdiel;
                obj.SolverStruct.strdiel.selfintdiel=intdiel;
                obj.SolverStruct.strdiel.selfintmetaldiel=intmetaldiel;
                obj.SolverStruct.const=const;
                obj.MesherStruct.Mesh.dielEdges=strdiel.EdgesTotal;
            end



            obj.MesherStruct.Mesh.numEdges=EdgesTotal;
            obj.SolverStruct.RWG=metalbasis;
            obj.SolverStruct.RWG.TrianglesTotal=TrianglesTotal;
            obj.SolverStruct.RWG.EdgesTotal=EdgesTotal;
            obj.SolverStruct.RWG.feededge=feededge;
            obj.SolverStruct.RWG.selfint=selfint;
            resetHasMeshChanged(obj);
            obj.MesherStruct.HasTaperChanged=0;
            if isprop(obj,'SolverType')
                setHasSolverChanged(obj,false);
                setHasSolverTypeChanged(obj,false);
            end
        end

        if calculate_dynamic_soln&&D
            omega=2*pi*frequency;

            V=voltagevector(obj,ElemNumber,omega,pwavesource);

            if(isa(obj,'rfpcb.PrintedLine')||isa(obj,'pcbComponent'))
                [ZL,loadedge]=loadingedgerfpcb(obj,calculate_load,frequency,Zterm,...
                addtermination,hwait);
            else
                [ZL,loadedge]=loadingedge(obj,calculate_load,frequency,Zterm,...
                addtermination,hwait);
            end


























            I=emsolver(obj,V,ZL,loadedge,omega);

            savesolution(obj,I,frequency,addtermination,ElemNumber);
        end
    end
end
