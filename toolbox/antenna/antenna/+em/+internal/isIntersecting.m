function[intersection]=isIntersecting(p_element,t_element,geomdata)















    intersection=0;



    t_element=cellfun(@(x)x(1:3,:),t_element,'UniformOutput',false);



    pbox=zeros(3,2,size(p_element,1));

    intersection_array=zeros(size(p_element,1));

    maxdimen=size(p_element{1},2);

    maxEdgeLength=zeros(1,size(p_element,1));



    for i=1:(size(p_element,1))
        if size(p_element{i},2)~=max(t_element{i}(:))
            p_element{i}=p_element{i}(:,1:max(t_element{i}(:)));
        end
        pbox(1:3,1:2,i)=pminpmax(p_element{i});
        if size(p_element{i},2)>maxdimen
            maxdimen=size(p_element{i},2);
        end
    end


    box_element=zeros(3,maxdimen,size(p_element,1));


    t1_element=cell(size(t_element,1),1);
    for i=1:(size(p_element,1))
        t1_element{i}=t_element{i}(1:3,:);
    end



    for i=1:(size(p_element,1))
        box_element(1:3,:,i)=[p_element{i}...
        ,repmat(p_element{i}(:,1).*ones(3,1),1,maxdimen-size(p_element{i},2))];
        [maxEdgeLength(i)]=findEdgeLength(p_element{i},t1_element{i});
    end


    for i=1:(size(p_element,1))
        [intersection_array(i,1:size(p_element,1))]=boxIntersection(pbox(:,:,i),...
        box_element,max(maxEdgeLength));

        intersection_array(i,i)=0;
    end



    if~any(intersection_array,1)
        return;
    end


    [box_array_row,box_array_col]=ind2sub(size(intersection_array),...
    find(intersection_array==1));
    intersection_box=unique(sort([box_array_row,box_array_col],2),'rows');


    normal=cell(max(max(intersection_box)),1);
    edgesb=cell(max(max(intersection_box)),1);



    geomdata_check1=isempty(geomdata)||...
    (size(geomdata.polygons,2)~=size(p_element,1));
    geomdata_check2=false;
    if~geomdata_check1
        for i=1:(size(p_element,1))
            temp_polygons=geomdata.polygons{i};
            temp_polygons=unique(temp_polygons(:));
            c=intersect(p_element{i}',...
            geomdata.BorderVertices(temp_polygons,:),'rows');
            if isempty(c)
                geomdata_check2=true;
            end
        end
    end

    if geomdata_check1||geomdata_check2
        temp.BorderVertices=p_element{1}';
        temp.polygons{1}=t1_element{1}';
        for i=2:size(p_element,1)
            temp.BorderVertices=[temp.BorderVertices;p_element{i}'];
            temp.polygons{i}=t1_element{i}'+max(max(temp.polygons{i-1}));
        end
        geomdata=temp;
    end


    for i=1:size(intersection_box,1)
        AABB1=intersection_box(i,1);
        AABB2=intersection_box(i,2);
        [intersection,normal{AABB1},normal{AABB2},edgesb{AABB1},...
        edgesb{AABB2}]=isIntersectingset(p_element{AABB1},...
        t1_element{AABB1},p_element{AABB2},t1_element{AABB2},...
        geomdata.BorderVertices,geomdata.polygons{1,AABB1},...
        geomdata.polygons{1,AABB2},normal{AABB1},normal{AABB2},...
        edgesb{AABB1},edgesb{AABB2},pbox(:,:,AABB1),pbox(:,:,AABB2));
        if any(intersection)
            break;
        end
    end
end

function[intersection,normal1,normal2,edgesb1,edgesb2]=isIntersectingset(p1,t1,p2,t2,p,poly1,poly2,normal1,normal2,edgesb1,edgesb2,pbox1,pbox2)



























    intersection=0;

    ptemp=p';


    if isempty(edgesb1)||isempty(edgesb2)

        pcheck1=intersect(p(unique(poly1(:))',:),p1','rows');

        pcheck2=intersect(p(unique(poly2(:))',:),p1','rows');
        if(size(pcheck2,1)>size(pcheck1,1))
            temp=poly1;
            poly1=poly2;
            poly2=temp;
        end
    end


    if isempty(edgesb1)

        for i=1:size(poly1,1)
            poly11a=poly1(i,:);
            poly11b=[poly11a;circshift(poly11a,-1,2)];
            temp_edgesb1=edgesb1;
            edgesb1=[temp_edgesb1;poly11b'];
        end

        edgesb1=unique(sort(edgesb1,2),'rows');
    end


    [inner_edges1a]=boxIntersection_segment(pbox2,p(edgesb1(:,1),:)',...
    p(edgesb1(:,2),:)');
    inner_edges1=find(inner_edges1a);










    if isempty(edgesb2)
        for i=1:size(poly2,1)
            poly22a=poly2(i,:);
            poly22b=[poly22a;circshift(poly22a,-1,2)];
            temp_edgesb2=edgesb2;
            edgesb2=[temp_edgesb2;poly22b'];
        end

        edgesb2=unique(sort(edgesb2,2),'rows');
    end


    [inner_edges2a]=boxIntersection_segment(pbox1,p(edgesb2(:,1),:)',...
    p(edgesb2(:,2),:)');
    inner_edges2=find(inner_edges2a);


    t1=t1';
    p1temp=p1';
    t2=t2';
    p2temp=p2';



    vert11=p1(:,t1(:,1))';
    vert12=p1(:,t1(:,2))';
    vert13=p1(:,t1(:,3))';


    vert21=p2(:,t2(:,1))';
    vert22=p2(:,t2(:,2))';
    vert23=p2(:,t2(:,3))';


    if isempty(normal1)
        normals1=cross(vert11-vert12,vert11-vert13,2);
        normals1det=repmat(sqrt(sum(normals1.*normals1,2)),1,size(normals1,2));
        normals1=normals1./normals1det;
        normal1=unique(normals1,'rows');
    end


    if isempty(normal2)
        normals2=cross(vert21-vert22,vert21-vert23,2);
        normals2det=repmat(sqrt(sum(normals2.*normals2,2)),1,size(normals2,2));
        normals2=normals2./normals2det;
        normal2=unique(normals2,'rows');
    end


    if size(normal1,1)>size(normal2,1)
        temp=normal1;
        normal1=normal2;
        normal2=temp;
    end
    C=cross(repmat(reshape(normal1',1,3,size(normal1,1)),...
    max(size(normal1,1),size(normal2,1)),1,1),...
    repmat(normal2,1,1,size(normal1,1)),2);

    Cnorm=sqrt(sum(C.^2,2));


    if find(Cnorm==0)



        point1=p(edgesb1(:,1),:);
        vector1=p(edgesb1(:,2),:)-p(edgesb1(:,1),:);


        point2=p(edgesb2(:,1),:);
        vector2=p(edgesb2(:,2),:)-p(edgesb2(:,1),:);



        if~isempty(inner_edges1)
            if size(inner_edges1,2)~=size(edgesb1,1)
                for n=1:size(inner_edges1,2)
                    m=inner_edges1(n);
                    point1a=repmat(point1(m,:),size(vector2,1),1);
                    vector1a=repmat(vector1(m,:),size(vector2,1),1);
                    intersection=segment_segment(point1a,vector1a,point2,vector2);
                    if intersection
                        return;
                    end
                end


            elseif size(inner_edges1,2)==size(edgesb1,1)

                edges2=[t2(:,[1,2]);t2(:,[1,3]);t2(:,[2,3])];

                edges2=unique(sort(edges2,2),'rows');

                point2n=p2temp(edges2(:,1),:);
                vector2n=p2temp(edges2(:,2),:)-p2temp(edges2(:,1),:);
                for m=1:size(point1,1)
                    point1a=repmat(point1(m,:),size(vector2n,1),1);
                    vector1a=repmat(vector1(m,:),size(vector2n,1),1);
                    intersection=segment_segment(point1a,vector1a,point2n,vector2n);
                    if intersection
                        return;
                    end
                end
            end
        end



        if~isempty(inner_edges2)
            if size(inner_edges2,2)~=size(edgesb2,1)
                for k=1:size(inner_edges2,2)
                    m=inner_edges2(k);
                    point2a=repmat(point2(m,:),size(vector1,1),1);
                    vector2a=repmat(vector2(m,:),size(vector1,1),1);
                    intersection=segment_segment(point2a,vector2a,point1,vector1);
                    if intersection
                        return;
                    end
                end


            elseif size(inner_edges2,2)==size(edgesb2,1)
                edges1=[t1(:,[1,2]);t1(:,[1,3]);t1(:,[2,3])];
                edges1=unique(sort(edges1,2),'rows');
                point2n=p1temp(edges1(:,1),:);
                vector2n=p1temp(edges1(:,2),:)-p1temp(edges1(:,1),:);
                for m=1:size(point2,1)
                    point2a=repmat(point2(m,:),size(vector2n,1),1);
                    vector2a=repmat(vector2(m,:),size(vector2n,1),1);
                    intersection=segment_segment(point2a,vector2a,point2n,vector2n);
                    if intersection
                        return;
                    end
                end
            end
        end



        if isequal(normal1,normal2)&&size(normal1,1)==1&&size(normal2,1)==1
            return;
        end
    end








    vert1=p1(:,t1(:,1))';
    vert2=p1(:,t1(:,2))';
    vert3=p1(:,t1(:,3))';


    for k=1:size(inner_edges2,2)
        m=inner_edges2(k);

        orig0=ptemp(:,edgesb2(m,1))';

        dest0=ptemp(:,edgesb2(m,2))';
        dir0=(dest0-orig0);

        dist0=sqrt(dir0*dir0');

        dir0=dir0/dist0;

        orig=repmat(orig0,size(vert1,1),1);
        dist=repmat(dist0,size(vert1,1),1);
        dir=repmat(dir0,size(vert1,1),1);

        [t]=em.internal.SegmentTriangleIntersection(orig,dir,vert1,vert2,vert3,dist);
        if any(t)&&isnumeric(t)
            intersection=1;
            return;
        end
    end


    vert1=p2(:,t2(:,1))';
    vert2=p2(:,t2(:,2))';
    vert3=p2(:,t2(:,3))';


    for n=1:size(inner_edges1,2)
        m=inner_edges1(n);
        orig0=ptemp(:,edgesb1(m,1))';
        dest0=ptemp(:,edgesb1(m,2))';
        dir0=(dest0-orig0);
        dist0=sqrt(dir0*dir0');
        dir0=dir0/dist0;
        orig=repmat(orig0,size(vert1,1),1);
        dist=repmat(dist0,size(vert1,1),1);
        dir=repmat(dir0,size(vert1,1),1);
        [t]=em.internal.SegmentTriangleIntersection(orig,dir,vert1,vert2,vert3,dist);
        if any(t)&&isnumeric(t)
            intersection=1;
            return;
        end
    end
end

function[intersection_array]=boxIntersection(pref,pbox,alpha)
















    alpha1=0;
    alpha2=0;
    alpha3=0;

    if pref(1,2)-pref(1,1)<alpha
        alpha1=alpha;
    end
    if pref(2,2)-pref(2,1)<alpha
        alpha2=alpha;
    end
    if pref(3,2)-pref(3,1)<alpha
        alpha3=alpha;
    end


    check1x=(pbox(1,:,:)>=(pref(1,1)-alpha1))&...
    (pbox(1,:,:)<=(pref(1,2)+alpha1));
    check1y=(pbox(2,:,:)>=(pref(2,1)-alpha2))&...
    (pbox(2,:,:)<=(pref(2,2)+alpha2));
    check1z=(pbox(3,:,:)>=(pref(3,1)-alpha3))&...
    (pbox(3,:,:)<=(pref(3,2)+alpha3));
    check0=(check1x&check1y&check1z);

    check1=any(check0);
    intersection_array=reshape(check1,1,numel(check1));
end

function[Intersection]=segment_segment(point1,vector1,point2,vector2)



















    Intersection=0;

    num1=cross((point2-point1),vector1,2);
    num2=cross(vector1,vector2);
    denum=dot(num2,num2,2);


    check1=(sqrt(sum(num2.*num2,2))==0)&(sqrt(sum(num1.*num1,2))~=0);
    if all(check1)
        return;
    end


    check2=(sqrt(sum(num2.*num2,2))==0)&(sqrt(sum(num1.*num1,2))==0);


    if any(check2)





        t0=dot((point2-point1),vector1,2)./dot(vector1,vector1,2);
        t1=dot((point2+vector2-point1),vector1,2)./dot(vector1,vector1,2);

        t0a=t0(check2);
        t1a=t1(check2);

        check2a=(t0a>=0)&(t0a<=1);
        check2b=(t1a<=1)&(t1a>=0);
        if any(check2a)||any(check2b)
            Intersection=1;
            return;
        end
    end


    u=dot(num1,num2,2)./denum;
    t=dot(cross((point2-point1),vector2,2),num2,2)./denum;


    check3b=(sqrt(sum(num2.*num2,2))~=0)&(u>=0&u<=1)&(t>=0&t<=1);



    equality_check=(point1(check3b,:)+...
    (repmat(t(check3b),1,size(vector1(check3b,:),2)).*vector1(check3b,:)))...
    -(point2(check3b,:)+(repmat(u(check3b),1,size(vector2(check3b,:),2)).*vector2(check3b,:)));


    if find(abs(sqrt(sum(dot(equality_check,equality_check,2),2)))<1e-12)
        Intersection=1;
    end
end


function[pm]=pminpmax(p)










    pm=[min(p,[],2),max(p,[],2)];
end

function[check0]=boxIntersection_segment(pref,pedgeb1,pedgeb2)













    check1x=(pedgeb1(1,:)<pref(1,1))&(pedgeb2(1,:)<pref(1,1))|(pedgeb1(1,:)>pref(1,2))&(pedgeb2(1,:)>pref(1,2));
    check1y=(pedgeb1(2,:)<pref(2,1))&(pedgeb2(2,:)<pref(2,1))|(pedgeb1(2,:)>pref(2,2))&(pedgeb2(2,:)>pref(2,2));
    check1z=(pedgeb1(3,:)<pref(3,1))&(pedgeb2(3,:)<pref(3,1))|(pedgeb1(3,:)>pref(3,2))&(pedgeb2(3,:)>pref(3,2));
    check0=(check1x&check1y&check1z);
    check0=not(check0);
    check0=reshape(check0,1,numel(check0));
end

function[maxEdgeLength]=findEdgeLength(p,t)









    t1=t(1:3,:)';
    Points=p';


    edges1=[t1(:,[1,2]);t1(:,[1,3]);t1(:,[2,3])];
    e=unique(sort(edges1,2),'rows');


    edgeLength=sqrt((Points(e(:,2),1)-Points(e(:,1),1)).^2+...
    (Points(e(:,2),2)-Points(e(:,1),2)).^2+...
    (Points(e(:,2),3)-Points(e(:,1),3)).^2);


    maxEdgeLength=max(edgeLength);
end















