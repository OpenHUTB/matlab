function posolver(obj,frequency,kvector,polvector,sourceloc,P,T,enablegpu)















    [calculate_static_soln,calculate_dynamic_soln]=checkrcscache(obj,...
    frequency,kvector,...
    polvector);
    N=size(sourceloc,2);
    if calculate_static_soln
        p=obj.MesherStruct.Mesh.p;
        t=obj.MesherStruct.Mesh.t;
        t(4,:)=0;
        idPO=true(1,size(t,2));
        metalbasis=em.EmStructures.basis_po(p,t);

        if isprop(obj,'FeedLocation')&&~isa(obj,'platform')
            if any(strcmpi(obj.MesherStruct.Mesh.FeedType,'multiedge'))
                feededge=em.EmStructures.getFeedEdges(obj,p,metalbasis);
                metalbasis=em.EmStructures.alignfeedcurrents(metalbasis,...
                t,feededge,class(obj));
            else
                if isprop(obj,'Element')
                    feededge=em.EmStructures.feeding_edge(p,metalbasis.Edges,...
                    obj.FeedLocation,obj.MesherStruct.Mesh.FeedType,obj.Element);
                else
                    feededge=em.EmStructures.feeding_edge(p,metalbasis.Edges,...
                    obj.FeedLocation,obj.MesherStruct.Mesh.FeedType);
                end
            end
        else
            feededge=[];
        end
        mode='location';

        if~enablegpu

            metalbasis=em.EmStructures.findLitRegionsEm(metalbasis,p,t,idPO,sourceloc,mode);
        else

            metalbasis=em.EmStructures.findLitRegionsOnGpu(metalbasis,p,t,idPO,sourceloc,mode);
        end




        obj.MesherStruct.Mesh.numEdges=metalbasis.EdgesTotal;
        obj.MesherStruct.Mesh.numPOEdges=metalbasis.EdgesTotal;
        obj.SolverStruct.RWG=metalbasis;
        obj.SolverStruct.RWG.feededge=feededge;


        obj.MesherStruct.HasMeshChanged=1;
        obj.MesherStruct.HasTaperChanged=0;
    end

    if calculate_dynamic_soln

        IPO=zeros(obj.SolverStruct.RWG.EdgesTotal,size(sourceloc,2));

        epsilon0=8.85418782e-012;
        mu0=1.25663706e-006;
        eta=sqrt(mu0/epsilon0);
        k0=2*pi*frequency/em.MeshGeometry.speedOfLight(1,1);

        if N>2
            msg=sprintf('Calculating PO current for %d incident angles',...
            N);
            hwaitpo=waitbar(0,msg,'Name','Plane-wave sweep',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            setappdata(hwaitpo,'canceling',0)
        else
            hwaitpo=[];
        end

        for n=1:N
            k=k0*kvector(:,n);
            Pol=polvector(:,n);
            Polh=cross(k,Pol)/k0;


            polmat=repmat(Polh,[1,obj.SolverStruct.RWG.EdgesTotal]);
            dir=repmat(k,[1,obj.SolverStruct.RWG.EdgesTotal]);
            kr=dot(dir,obj.SolverStruct.RWG.RWGCenter,1);
            Hinc=((1/eta)*polmat.*repmat(exp(-1i*kr),[3,1]));








            temp_IPO=dot(Hinc.',obj.SolverStruct.RWG.RWGevector.',2);
            IPO(:,n)=2*obj.SolverStruct.RWG.Lit(:,n).*temp_IPO;
            if N>2

                if getappdata(hwaitpo,'canceling')
                    status=1;
                    break
                end
                msg=sprintf('Calculating PO current for %d/%d incident angles',...
                n,N);
                waitbar(n/N,hwaitpo,msg);
            end
        end
        if N>2
            delete(hwaitpo);
        end



        savercssolution(obj,IPO,frequency,P,T);
    end



end
