function[P,t_boundary]=getHardFaces(P_bottom,tbottom,P_top,ttop,p_hard1,p_hard2,H)
    index_side=boundary(P_bottom(:,1),P_bottom(:,2));
    P_side=[P_bottom(index_side,:);P_top(index_side,:)];
    P=[P_bottom;P_top];
    p_left=P(P(:,1)==min(P_side(:,1)),:);
    p_right=P(P(:,1)==max(P_side(:,1)),:);
    p_front=P(P(:,2)==max(P_side(:,2)),:);
    p_back=P(P(:,2)==min(P_side(:,2)),:);

    DT_left=delaunayTriangulation(p_left(:,2:3));
    t_left=DT_left.ConnectivityList;
    DT_right=delaunayTriangulation(p_right(:,2:3));
    t_right=DT_right.ConnectivityList;
    DT_front=delaunayTriangulation(p_front(:,1),p_front(:,3));
    t_front=DT_front.ConnectivityList;
    DT_back=delaunayTriangulation(p_back(:,1),p_back(:,3));
    t_back=DT_back.ConnectivityList;

    t_left_new=reshape(t_left,[],1);
    t_right_new=reshape(t_right,[],1);
    t_front_new=reshape(t_front,[],1);
    t_back_new=reshape(t_back,[],1);

    for i=1:max(size(p_left))
        new_index=find(P(:,1)==p_left(i,1)&P(:,2)==p_left(i,2)&...
        P(:,3)==p_left(i,3));
        t_left_new(t_left==i)=new_index;
    end
    t_left=reshape(t_left_new,[],3);

    for i=1:max(size(p_right))
        new_index=find(P(:,1)==p_right(i,1)&P(:,2)==p_right(i,2)&...
        P(:,3)==p_right(i,3));
        t_right_new(t_right==i)=new_index;
    end
    t_right=reshape(t_right_new,[],3);

    for i=1:max(size(p_front))
        new_index=find(P(:,1)==p_front(i,1)&P(:,2)==p_front(i,2)&...
        P(:,3)==p_front(i,3));
        t_front_new(t_front==i)=new_index;
    end
    t_front=reshape(t_front_new,[],3);

    for i=1:max(size(p_back))
        new_index=find(P(:,1)==p_back(i,1)&P(:,2)==p_back(i,2)&...
        P(:,3)==p_back(i,3));
        t_back_new(t_back==i)=new_index;
    end
    t_back=reshape(t_back_new,[],3);




    t_boundary=[tbottom;t_left;t_right;t_front;t_back;ttop];



    t_hard=[];

    if~isempty(p_hard1)&&~isempty(p_hard2)
        p_combine=unique([p_hard1;p_hard2],'row','stable');
        p_combine_top=p_combine;
        p_combine_top(:,3)=p_combine(:,3)+H(1);
        p_total=[p_combine;p_combine_top];
        p_x=unique(p_total(:,1));

        for index=1:max(size(p_x))
            p_temp=p_total(p_total(:,1)==p_x(index),:);
            TR=delaunayTriangulation(p_temp(:,2:3));
            t_temp=TR.ConnectivityList;
            t_temp_new=reshape(t_temp,[],1);
            for index2=1:max(size(t_temp_new))
                current_index=t_temp_new(index2);
                new_index=find(P(:,1)==p_temp(current_index,1)&...
                P(:,2)==p_temp(current_index,2)&P(:,3)==p_temp(current_index,3));
                t_temp_new(index2)=new_index(1);
            end
            t_temp=reshape(t_temp_new,[],3);
            t_hard=[t_hard;t_temp];
        end
    end

    t_boundary=[t_boundary;t_hard];