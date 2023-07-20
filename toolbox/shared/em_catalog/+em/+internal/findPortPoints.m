function[portpoint1,portpoint2,t1,t2]=findPortPoints(P,t,feedpoint)




    warnflag=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');

    T=triangulation(t(:,1:3),P(:,1:2));
    warning(warnflag);
    e=edges(T);
    [m,n]=size(feedpoint);

    if n==2
        feedpoint(:,3)=0;
    end
    portpoint1=zeros(m,3);
    portpoint2=zeros(m,3);
    t1=[];
    t2=[];
    exitFunction=false;
    for j=1:m

        feedpoint_p=feedpoint(j,:)+5*[sqrt(eps),sqrt(eps),0];
        feedpoint_n=feedpoint(j,:)-5*[sqrt(eps),sqrt(eps),0];




        tIDFeed1=pointLocation(T,feedpoint_p(:,1:2));
        tIDFeed2=pointLocation(T,feedpoint_n(:,1:2));



        tf1=isnan(tIDFeed1)||isnan(tIDFeed2);
        tf2=isequal(tIDFeed1,tIDFeed2);
        tf3=xor(isnan(tIDFeed1),isnan(tIDFeed2));







        if tf2




            if n==2
                [D,IND]=em.internal.meshprinting.inter2_point_seg(P(:,1:2),e,feedpoint(j,1:2));
            else
                [D,IND]=em.internal.meshprinting.inter2_point_seg(P,e,feedpoint(j,:));
            end
            tempIndex=find(D<sqrt(eps)&IND==-1);%#ok<AGROW>
            if~isempty(tempIndex)
                ecommon=e(tempIndex,:);
                IDt=edgeAttachments(T,ecommon(1),ecommon(2));
                IDt=IDt{1};
                tIDFeed1=IDt(1);
                tIDFeed2=IDt(2);
                tf2=false;
                portpoint1(j,:)=P(ecommon(1),:);
                portpoint2(j,:)=P(ecommon(2),:);
            else

                tf2=true;
                tf3=false;
            end
        end

        if~tf1&&~tf2
            tempt1=T.ConnectivityList(tIDFeed1,1:3);
            tempt2=T.ConnectivityList(tIDFeed2,1:3);
            commonEdge=intersect(tempt1,tempt2);













            if isequal(numel(commonEdge),1)
                n=neighbors(T,tIDFeed1);

                n=n(~isnan(n));
                cc=circumcenter(T,n');
                [k,~]=dsearchn(cc,feedpoint(j,1:2));
                tIDFeed2=n(k);

                tempt1=T.ConnectivityList(tIDFeed1,1:3);
                tempt2=T.ConnectivityList(tIDFeed2,1:3);
                commonEdge=intersect(tempt1,tempt2);
            end
            feedVertices=P(commonEdge,:);

            portpoint1(j,:)=feedVertices(1,:);
            portpoint2(j,:)=feedVertices(2,:);

            t1=[t1;T.ConnectivityList(tIDFeed1,1:3)];%#ok<AGROW>
            t2=[t2;T.ConnectivityList(tIDFeed2,1:3)];%#ok<AGROW>        
        elseif tf3
























            if n==2
                [D,IND]=em.internal.meshprinting.inter2_point_seg(P(:,1:2),e,feedpoint(j,1:2));
            else
                [D,IND]=em.internal.meshprinting.inter2_point_seg(P,e,feedpoint(j,:));
            end
            tempIndex=find(D<sqrt(eps)&IND==-1);%#ok<AGROW>
            if~isempty(tempIndex)
                ecommon=e(tempIndex,:);
                IDt=edgeAttachments(T,ecommon(1),ecommon(2));
                tIDFeed=IDt{1};
                portpoint1(j,:)=P(ecommon(1),:);
                portpoint2(j,:)=P(ecommon(2),:);
                t1=T.ConnectivityList(tIDFeed,1:3);
                t2=[];
            else
                portpoint1=[];
                portpoint2=[];
                t1=[];
                t2=[];
                exitFunction=true;
            end



        else
            exitFunction=true;
            portpoint1=[];
            portpoint2=[];
        end

        if exitFunction














            return;
        end

    end
end




























