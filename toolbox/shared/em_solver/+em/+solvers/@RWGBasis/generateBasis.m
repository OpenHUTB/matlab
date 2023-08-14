function generateBasis(obj)








    generateNormals(obj);
    P=obj.Mesh.P;
    t=obj.Mesh.t;
    normals=obj.Normals;
    out=findEdgeGroups(obj,t);
    if size(out,1)==3
        numIndx=4;
    else
        numIndx=3;
    end
    if size(out,1)>2
        numIndx=size(out,1)+1;
    else
        numIndx=3;
    end












    obj.SolidIndicator=isempty(out{1});

    for k=2:size(out,1)

        x=out{k};
        if k==2
            edges=x(1:2:end,1:2);
            TriP=x(1:2:end,3);
            TriM=x(2:2:end,3);
        else
            newEdges=[];
            newTriP=[];
            newTriM=[];

            for i=1:k:size(x,1)
                xi=x(i:i+k-1,:);

                newEdges=[newEdges;xi(1:k-1,1:2)];
                nFound=0;
                for j1=2:k
                    for j2=1:j1-1
                        if nFound<k-1&&xi(j1,5)~=xi(j2,5)
                            newTriP=[newTriP;xi(j1,3)];
                            newTriM=[newTriM;xi(j2,3)];

                            nFound=nFound+1;
                        end
                    end
                end
                if nFound<k-1
                    for j1=2:k
                        for j2=1:j1-1
                            if nFound<k-1
                                newTriP=[newTriP;xi(j1,3)];
                                newTriM=[newTriM;xi(j2,3)];
                                nFound=nFound+1;
                            end
                        end
                    end
                end

            end




            edges=[newEdges;edges];%#ok<AGROW>
            TriP=[newTriP;TriP];%#ok<AGROW>
            TriM=[newTriM;TriM];%#ok<AGROW>

        end
    end




    tt=[TriP,TriM];
    [ttm,idt]=sortrows(tt);
    TriP=ttm(:,1);
    TriM=ttm(:,2);
    edges=edges(idt,:);
    Edge=edges;
    temp=P(edges(:,1),:)-P(edges(:,2),:);
    EdgeLength=sqrt(dot(temp,temp,2));
    FacesTotal=size(t,1);
    EdgesTotal=size(edges,1);
    d12=P(t(:,2),:)-P(t(:,1),:);
    d13=P(t(:,3),:)-P(t(:,1),:);
    temp=cross(d12,d13,2);
    AreaF=0.5*sqrt(dot(temp,temp,2));
    CenterF=1/3*(P(t(:,1),:)+P(t(:,2),:)+P(t(:,3),:));
    edgeSum=sum(edges,2);
    VerP=sum(t(TriP,1:3),2)-edgeSum;
    VerM=sum(t(TriM,1:3),2)-edgeSum;


    e2t=[TriP,TriM];

    for m=1:EdgesTotal
        relVerP(m)=find(t(e2t(m,1),1:3)==VerP(m));
        relVerM(m)=find(t(e2t(m,2),1:3)==VerM(m));
    end


    FCRhoP=+(CenterF(TriP,:)-P(VerP,:));
    FCRhoM=-(CenterF(TriM,:)-P(VerM,:));
    Facesize=zeros(1,FacesTotal);
    for m=1:FacesTotal
        VertexesIntes=P(t(m,1:3),:);
        for n=1:3
            tempfacesize(n)=norm(CenterF(m,:)-VertexesIntes(n,:));
        end
        Facesize(m)=max(tempfacesize);
    end


    RWGCenter=1/2*(P(edges(:,1),:)+P(edges(:,2),:));
    RWGevector=zeros(EdgesTotal,3);
    RWGNormal=zeros(EdgesTotal,3);
    for n=1:EdgesTotal
        t1=TriP(n);
        t2=TriM(n);
        evector=P(edges(n,1),:)-P(edges(n,2),:);
        tp=cross(normals(t1,:),evector);
        tp=sign(dot(tp,FCRhoP(n,:)))*tp;
        tm=cross(normals(t2,:),evector);
        tm=sign(dot(tm,FCRhoM(n,:)))*tm;
        RWGtvector=1/2*(tp+tm);
        RWGtvector=RWGtvector/norm(RWGtvector);





        RWGNormal(n,:)=1/2*(normals(t1,:)+normals(t2,:));



        CROSS=cross(evector,RWGtvector);
        DOT=dot(CROSS,RWGNormal(n,:));
        RWGevector(n,:)=sign(DOT)*evector/norm(evector);
    end


    DipoleCenter=zeros(EdgesTotal,3);
    DipoleMoment=zeros(EdgesTotal,3);
    for m=1:EdgesTotal
        Point1=CenterF(TriP(m),:);
        Point2=CenterF(TriM(m),:);
        DipoleCenter(m,:)=0.5*(Point1+Point2);
        DipoleMoment(m,:)=EdgeLength(m)*(-Point1+Point2);
    end


    BFlength=zeros(FacesTotal,1);
    BFnumber=ones(FacesTotal,numIndx);
    BFcharge=zeros(FacesTotal,numIndx);
    BFrhox=zeros(FacesTotal,numIndx);
    BFrhoy=zeros(FacesTotal,numIndx);
    BFrhoz=zeros(FacesTotal,numIndx);

    index1=cell(FacesTotal,1);
    index2=cell(FacesTotal,1);
    for ii=1:length(TriP)
        index1{TriP(ii)}=[index1{TriP(ii)},ii];
        index2{TriM(ii)}=[index2{TriM(ii)},ii];
    end
    for m=1:FacesTotal
        length1=length(index1{m});
        length2=length(index2{m});
        BFlength(m)=length1+length2;
        for n=1:length1
            BFnumber(m,n)=index1{m}(n);
            BFcharge(m,n)=+EdgeLength(index1{m}(n));
            BFrhox(m,n)=(EdgeLength(index1{m}(n))/2)*FCRhoP(index1{m}(n),1);
            BFrhoy(m,n)=(EdgeLength(index1{m}(n))/2)*FCRhoP(index1{m}(n),2);
            BFrhoz(m,n)=(EdgeLength(index1{m}(n))/2)*FCRhoP(index1{m}(n),3);
        end
        for n=1:length2
            BFnumber(m,n+length1)=index2{m}(n);





            BFcharge(m,n+length1)=-EdgeLength(index2{m}(n));
            BFrhox(m,n+length1)=(EdgeLength(index2{m}(n))/2)*FCRhoM(index2{m}(n),1);
            BFrhoy(m,n+length1)=(EdgeLength(index2{m}(n))/2)*FCRhoM(index2{m}(n),2);
            BFrhoz(m,n+length1)=(EdgeLength(index2{m}(n))/2)*FCRhoM(index2{m}(n),3);
        end
    end


    temp=CenterF(TriP,:)-CenterF(TriM,:);
    RWGDistance=sqrt(sum(temp.*temp,2));


    AngleCorrection=1+0.5*(1-sum(normals(TriP,:).*normals(TriM,:),2));


    calculateSelfIntegrals(obj);
    IS=obj.SelfIntegral;
    Neighbors=[];
    maxdim=max([max(P(:,1))-min(P(:,1)),max(P(:,2))-min(P(:,2)),max(P(:,3))-min(P(:,3))]);


    geom.FacesTotal=FacesTotal;
    geom.EdgesTotal=EdgesTotal;

    geom.t=t;
    geom.P=P;
    geom.AreaF=AreaF;
    geom.CenterF=CenterF;
    geom.NormalF=normals;
    geom.Facesize=Facesize;
    geom.EdgeLength=EdgeLength;
    geom.Edge=Edge;
    geom.TriP=TriP;
    geom.TriM=TriM;
    geom.VerP=VerP;
    geom.VerM=VerM;
    geom.RelVerP=relVerP;
    geom.RelVerM=relVerM;
    geom.FCRhoP=FCRhoP;
    geom.FCRhoM=FCRhoM;
    geom.RWGCenter=RWGCenter;
    geom.RWGevector=RWGevector;
    geom.RWGNormal=RWGNormal;
    geom.DipoleCenter=DipoleCenter;
    geom.DipoleMoment=DipoleMoment;

    geom.BFlength=BFlength;
    geom.BFnumber=BFnumber;
    geom.BFcharge=BFcharge;
    geom.BFrhox=BFrhox;
    geom.BFrhoy=BFrhoy;
    geom.BFrhoz=BFrhoz;
    geom.RWGDistance=RWGDistance;
    geom.AngleCorrection=AngleCorrection;
    geom.IS=IS;
    geom.NumRWG=obj.NumRWG;
    geom.Neighbors=Neighbors;
    geom.MaxDimInMesh=maxdim;
    obj.MetalBasis=geom;
end

