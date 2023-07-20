function dielbasis=embedded_basis(dielbasis,t,AT,FacesNontrivial,const)























    tt=t(1:3,:)';
    tt1=[tt(:,1),tt(:,3),tt(:,2)];
    tt2=[tt(:,2),tt(:,1),tt(:,3)];
    tt3=[tt(:,3),tt(:,2),tt(:,1)];
    faces=dielbasis.Faces(:,1:FacesNontrivial);

    Index1=find(ismember(faces',tt,'rows'));
    Index2=find(ismember(faces',circshift(tt,1,2),'rows'));
    Index3=find(ismember(faces',circshift(tt,2,2),'rows'));
    Index4=find(ismember(faces',tt1,'rows'));
    Index5=find(ismember(faces',tt2,'rows'));
    Index6=find(ismember(faces',tt3,'rows'));

    val=[Index1;Index2;Index3;Index4;Index5;Index6];
    Index=unique(val);
    emdidx=find(AT(1,Index));
    EmbedFace=Index(emdidx).';
    FaceNumber=[Index.',Index(emdidx).'];
    TetNumber=[AT(2,Index),AT(1,Index(emdidx))];












    if~isempty(EmbedFace)
        ADD=dielbasis.EdgesTotal;
        for m=1:dielbasis.EdgesTotal
            [~,C1]=find(faces(:,EmbedFace)==dielbasis.Edge(1,m));
            [~,C2]=find(faces(:,EmbedFace)==dielbasis.Edge(2,m));
            F=intersect(C1,C2);

            if(length(F)==2)
                ADD=ADD+1;
                Faces=EmbedFace(F);
                Vector1=dielbasis.CenterF(:,Faces(1))-dielbasis.CenterF(:,Faces(2));
                Vector2=dielbasis.P(:,dielbasis.Edge(1,m))-dielbasis.P(:,dielbasis.Edge(2,m));
                Vector3=(dielbasis.P(:,dielbasis.Edge(1,m))+dielbasis.P(:,dielbasis.Edge(2,m)))/2;
                Vector4=cross(Vector1,Vector2);

                [R,C]=find(dielbasis.EdgesTN==m);
                for n=1:length(C)
                    Vector5=dielbasis.CenterT(:,C(n))-Vector3;
                    BF=dielbasis.BasisTC(:,R(n),C(n));
                    DOT=dot(Vector4,Vector5);

                    if DOT>0
                        dielbasis.EdgesTN(R(n),C(n))=ADD;
                        for p=1:2
                            Face=Faces(p);
                            if~isempty(find(AT(:,Face)==C(n)))%#ok<EFIND> % only one adjacent tet                        
                                IN=dot(BF,dielbasis.CenterF(:,Face)-dielbasis.CenterT(:,C(n)));
                                Contrast=const.Epsilon_r(C(n))*(1-1i*const.tan_delta(C(n)));
                                DiffContrast=(Contrast-const.epsilon)/Contrast;

                                temp=dielbasis.EdgesFNI(Face)+1;
                                dielbasis.DiffContrast_real(temp,Face)=sign(IN)*real(DiffContrast);
                                dielbasis.DiffContrast_imag(temp,Face)=sign(IN)*imag(DiffContrast);
                                dielbasis.EdgesFN(temp,Face)=ADD;
                                dielbasis.EdgesFNI(Face)=temp;
                            end
                        end
                    else
                        for p=1:2
                            Face=Faces(p);
                            if~isempty(find(AT(:,Face)==C(n)))%#ok<EFIND> % only one adjacent tet                        
                                Contrast=const.Epsilon_r(C(n))*(1-1i*const.tan_delta(C(n)));
                                DiffContrast=(Contrast-const.epsilon)/Contrast;
                                RF=find(dielbasis.EdgesFN(:,Face)==m);
                                IN=dot(BF,dielbasis.CenterF(:,Face)-dielbasis.CenterT(:,C(n)));
                                dielbasis.DiffContrast_real(RF,Face)=sign(IN)*real(DiffContrast);
                                dielbasis.DiffContrast_imag(RF,Face)=sign(IN)*imag(DiffContrast);
                            end
                        end
                    end
                end
            end
        end
        dielbasis.EdgesTotal=ADD;
    end


    dielbasis.BasisTCn=dielbasis.BasisTC;
    par=1.0;
    for m=1:length(FaceNumber)
        Vertexes=dielbasis.P(:,dielbasis.Faces(:,FaceNumber(m)));
        C1=Vertexes(:,1)-Vertexes(:,2);
        C2=Vertexes(:,1)-Vertexes(:,3);
        N=cross(C1,C2);
        N=N/norm(N);
        for n=1:6
            NormalComp=dot(dielbasis.BasisTC(:,n,TetNumber(m)),N)*N;
            TangComp=dielbasis.BasisTC(:,n,TetNumber(m))-NormalComp;
            dielbasis.BasisTCn(:,n,TetNumber(m))=par*NormalComp+(1-par)*TangComp;
        end
    end











































































































