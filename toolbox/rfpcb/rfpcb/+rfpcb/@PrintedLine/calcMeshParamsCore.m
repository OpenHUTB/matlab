function[maxel,minel,growthRate]=calcMeshParamsCore(obj,lambda,Aboard,Alayer,k)
















    layerId=find(cellfun(@(x)isa(x,'antenna.Shape'),obj.privateStack.Layers));
    metalLayers=find(cellfun(@(x)isa(x,'antenna.Shape'),obj.privateStack.Layers));
    Peri_phys=cellfun(@(x)perimeter(x.InternalPolyShape),obj.privateStack.Layers(metalLayers));
    [~,indx1]=max(Alayer);
    [~,indx2]=max(Peri_phys);

    metalLayer1=obj.privateStack.Layers{layerId(indx1)};
    TR1=triangulation(metalLayer1.InternalPolyShape);
    metalLayer2=obj.privateStack.Layers{layerId(indx2)};
    TR2=triangulation(metalLayer2.InternalPolyShape);
    P1=TR1.Points;
    e1=edges(TR1);
    P2=TR2.Points;
    e1=edges(TR1);
    F=freeBoundary(TR2);
    temp1=P1(e1(:,1),:)-P1(e1(:,2),:);
    edgelength1=sqrt(dot(temp1,temp1,2));
    temp2=P2(F(:,1),:)-P2(F(:,2),:);
    edgelength2=sqrt(dot(temp2,temp2,2));
    [edge_max1,~]=max(edgelength1);
    [edge_max2,~]=max(edgelength2);
    [edge_min1,~]=min(edgelength1);
    [edge_min2,~]=min(edgelength2);
    Area.Emax=edge_max1;
    Area.Emin=edge_min1;
    Area.Elength=edgelength1;
    Peri.Emax=edge_max2;
    Peri.Emin=edge_min2;
    Peri.Elength=edgelength2;

    [xlim,ylim]=boundingbox(obj.privateStack.BoardShape.InternalPolyShape);
    Xdim=max(xlim)-min(xlim);
    Ydim=max(ylim)-min(ylim);
    if 1==1
        [Xa,Xp]=estimateLambdaFraction(Area,Peri,lambda);
        if(0.75*lambda>max(Xdim,Ydim))

            maxel=sqrt(4*(lambda^2)/sqrt(3))/14;
            minel=sqrt(4*(lambda^2)/sqrt(3))/18;
        else
            maxel=sqrt(4*(lambda^2)/sqrt(3))/max(Xa,15);
            minel=sqrt(4*(lambda^2)/sqrt(3))/max(Xp,19);
        end
    else
        k1=8;
        N=1;
        maxel=sqrt(4*min(Alayer)*lambda*k1/(sqrt(3)*N));

        minel=lambda/10;



        t(:,4)=0;
        P(:,3)=0;
        basis=em.solvers.RWGBasis;
        basis.Mesh.P=P;
        basis.Mesh.t=t;
        generateBasis(basis);
        geom=basis.MetalBasis;
        NumRWG=ceil((lambda/mean(geom.RWGDistance)));

        if lambda/6>max(Xdim,Ydim)





        end
        Peri_phys=cellfun(@(x)perimeter(x.InternalPolyShape),obj.privateStack.Layers(metalLayers));
        Nsides=cellfun(@(x)numsides(x.InternalPolyShape),obj.privateStack.Layers(metalLayers));
        Es=Peri_phys./Nsides;
        N=round((lambda)./min(Es));
        minel=lambda/N;

        if round(lambda/minel)<10||round(lambda/minel)>50
            minel=mean([minel,lambda/12]);
        end

        if minel>maxel
            minel=k*maxel;
        end

    end


    minToMaxRatio=minel/maxel;
    setMeshMinToMaxEdgeRatio(obj,minToMaxRatio)



    growthRate=1+mean(Alayer./Aboard);






    if growthRate>1.95
        growthRate=1.95;
    elseif growthRate<1.05
        growthRate=1.05;
    end


    precision=1e2;
    growthRate=round(growthRate*precision)./precision;

    params.maxel=maxel;
    params.minel=minel;
    params.growthRate=growthRate;

end
function[Xa,Xp]=estimateLambdaFraction(Area,Peri,lambda)

    pe=mean(Peri.Elength);
    ae=mean(Area.Elength);
    Xp=ceil(sqrt(4*(lambda^2)/sqrt(3))./pe);
    Xa=ceil(sqrt(4*(lambda^2)/sqrt(3))./ae);



end



































































































