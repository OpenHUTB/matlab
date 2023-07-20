function updateMeshForPcbStack(obj,meshControlOptions)

    Hmax=meshControlOptions.Hmax;
    Cmin=meshControlOptions.Cmin;
    Grate=meshControlOptions.Grate;
    parentRoot=findParentRoot(obj);
    if~isempty(parentRoot)
        tf=all(strcmpi(getMeshMode(parentRoot),'manual'));
    else
        tf=strcmpi(getMeshMode(obj),'manual');
    end
    reMesh=true;
    numReMesh=0;
    if tf
        maxReMesh=2;
    else
        maxReMesh=3;
    end
    warnFlag=false;
    Hmaxcache=Hmax;
    Cmincache=Cmin;
    if~isequal(obj.MesherStruct.Mesh.MaxEdgeLength,Hmax)||...
        ~isequal(obj.MesherStruct.Mesh.MeshGrowthRate,Grate)||...
        ~(isequal(obj.MesherStruct.Mesh.MinContourEdgeLength,Cmin))||...
        checkHasStructureChanged(obj)

        setMeshGrowthRate(obj,Grate);

        while reMesh&&numReMesh<maxReMesh
            setMeshEdgeLength(obj,Hmax);
            setMeshMinContourEdgeLength(obj,Cmin);
            meshGenerator(obj);



            G=getGeometry(obj);
            maxFeatureSize=max(cellfun(@(x)x.MaxFeatureSize,G));



            p=obj.MesherStruct.Mesh.p';
            t=obj.MesherStruct.Mesh.t';
            warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
            if isa(obj,'pcbComponent')
                basis=em.solvers.RWGBasis;
                meshIn.P=p;
                meshIn.t=t(:,1:4);
                basis.Mesh=meshIn;
                generateBasis(basis);
                spacing=mean(basis.MetalBasis.RWGDistance);
                fmeshing=obj.MesherStruct.MeshingFrequency;
                epsr=obj.Substrate.EpsilonR;
                vp=em.MeshGeometry.speedOfLight(1,1)/sqrt(mean(epsr));
                if~isempty(fmeshing)
                    lambda=vp/fmeshing;
                    ElemsPerWavelength=lambda/spacing;
                    if ElemsPerWavelength<8
                        maxToMinRatio=Hmax/Cmin;
                        Hmax=min(Hmax/2,maxFeatureSize/3);
                        Cmin=Hmax/maxToMinRatio;
                        numReMesh=numReMesh+1;
                        warnFlag=true;
                    else
                        reMesh=false;
                    end
                else
                    reMesh=false;
                end
            else
                TR=triangulation(t(:,1:3),p);
                e=edges(TR);
                evec=p(e(:,2),:)-p(e(:,1),:);
                L=vecnorm(evec,2,2);
                eLmax=max(L);

                if(maxFeatureSize/eLmax)<3
                    maxToMinRatio=Hmax/Cmin;
                    Hmax=min(Hmax/2,maxFeatureSize/3);
                    Cmin=Hmax/maxToMinRatio;


                    if Hmax<obj.FeedWidth
                        Hmax=obj.FeedWidth+1e-10;
                    end
                    if any(Cmin<obj.FeedWidth)
                        Cmin=max(obj.FeedWidth);
                    end
                    numReMesh=numReMesh+1;
                    warnFlag=true;
                else
                    reMesh=false;
                end
            end
            warning(warnState);
        end


        if warnFlag&&tf
            setMeshEdgeLength(obj,Hmaxcache);
            setMeshMinContourEdgeLength(obj,Cmincache);




        end

    end

end