function[P]=inter3_con_con(P1,P2,Epsilon)







    e1(:,1)=[1:size(P1,1)]';
    e1(:,2)=[2:size(P1,1),1]';
    e2(:,1)=[1:size(P2,1)]';
    e2(:,2)=[2:size(P2,1),1]';


    temp=P1(e1(:,1),:)-P1(e1(:,2),:);
    length1=sqrt(dot(temp,temp,2));
    center1=0.5*(P1(e1(:,1),:)+P1(e1(:,2),:));
    temp=P2(e2(:,1),:)-P2(e2(:,2),:);
    length2=sqrt(dot(temp,temp,2));
    center2=0.5*(P2(e2(:,1),:)+P2(e2(:,2),:));



    E1=size(e1,1);
    E2=size(e2,1);
    e1new=[];
    P=[];
    for m=1:E1


        P=[P;P1(e1(m,1),:)];
        NewNodesAlongEdge_m=[];



        dummy=0.5*[repmat(length1(m),1,E2);length2'];



        temp=center2-repmat(center1(m,:),E2,1);
        dist=sqrt(dot(temp,temp,2));
        CLOSE=dist<sum(dummy,1)';
        indexint=find(CLOSE);
        lengthint=length(indexint);



        for n=1:lengthint
            n2=indexint(n);

            x1=P1(e1(m,:),1);
            y1=P1(e1(m,:),2);
            x2=P2(e2(n2,:),1);
            y2=P2(e2(n2,:),2);
            [x0,y0,indicator]=em.internal.meshprinting.inter1_seg_seg(x1,y1,x2,y2);
            if~isnan(x0)
                if indicator
                    NewNodesAlongEdge_m=[NewNodesAlongEdge_m;[x0,y0]];
                end
            else
                Q1=P2(e2(n2,1),:);
                Q2=P2(e2(n2,2),:);
                [D1,IND1]=em.internal.meshprinting.inter2_point_seg(P1(e1(m,:),:),[1,2],Q1);
                [D2,IND2]=em.internal.meshprinting.inter2_point_seg(P1(e1(m,:),:),[1,2],Q2);
                case1=IND1==-1&&D1<Epsilon;
                case2=IND2==-1&&D2<Epsilon;
                if case1||case2
                    dist11=norm(P1(e1(m,1),:)-Q1);
                    dist12=norm(P1(e1(m,1),:)-Q2);
                    dist21=norm(P1(e1(m,2),:)-Q1);
                    dist22=norm(P1(e1(m,2),:)-Q2);

                    if case1&&~case2&&dist11>Epsilon&&dist21>Epsilon
                        NewNodesAlongEdge_m=[NewNodesAlongEdge_m;Q1];
                    end

                    if~case1&&case2&&dist12>Epsilon&&dist22>Epsilon
                        NewNodesAlongEdge_m=[NewNodesAlongEdge_m;Q2];
                    end

                    if case1&&case2&&dist11>Epsilon&&dist21>Epsilon&&dist12>Epsilon&&dist22>Epsilon
                        NewNodesAlongEdge_m=[NewNodesAlongEdge_m;Q1;Q2];
                    end

                    if case1&&case2&&(dist11<Epsilon||dist21<Epsilon)&&dist12>Epsilon&&dist22>Epsilon
                        NewNodesAlongEdge_m=[NewNodesAlongEdge_m;Q2];
                    end

                    if case1&&case2&&dist11>Epsilon&&dist21>Epsilon&&(dist12<Epsilon||dist22<Epsilon)
                        NewNodesAlongEdge_m=[NewNodesAlongEdge_m;Q1];
                    end
                end
            end
        end


        NewNodesAlongEdge_m=unique(NewNodesAlongEdge_m,'rows','stable');
        new=size(NewNodesAlongEdge_m,1);
        if new>0
            temp1=NewNodesAlongEdge_m-repmat(P1(e1(m,1),:),new,1);
            dist1=sqrt(dot(temp1,temp1,2));
            [dummy,is]=sort(dist1);
            NewNodesAlongEdge_m=NewNodesAlongEdge_m(is,:);
            P=[P;NewNodesAlongEdge_m];
        end
    end



    [~,ip]=uniquetol(P,Epsilon,'ByRows',true,'DataScale',1);
    P=P(sort(ip),:);

end

