function[flag]=isLoadNotOnMetal(p_element,t_element,point,borders,...
    polygons)















    [p_element,e]=engunits(p_element);
    point=e*point;
    borders=e*borders;

    if size(t_element,1)>1000
        S_patch=reducepatch(t_element,p_element,0.2);
        p_element=S_patch.vertices;
        t_element=S_patch.faces;
    end



    flag=0;


    load=intersect(p_element,point,'rows');
    if~isempty(load)
        return
    end




    check=AABB(point,p_element);
    if~check
        flag=1;
        return
    end


    vert1=p_element(t_element(:,1),:);
    vert2=p_element(t_element(:,2),:);
    vert3=p_element(t_element(:,3),:);
    centroid=(vert1+vert2+vert3)/3;


    load=intersect(centroid,point,'rows');
    if~isempty(load)
        return
    end


    for i=1:size(polygons,2)
        metal_polygons=polygons{i};
        for j=1:size(metal_polygons,1)
            boundary_vertices=borders(metal_polygons(j,:)',:);
            plane_test=unique(boundary_vertices(:,1));
            if size(plane_test,1)==1&&plane_test==point(1,1)
                warnState=warning('Off','MATLAB:inpolygon:ModelingWorldLower');
                [in,on]=inpolygon(point(1,2),point(1,3),boundary_vertices(:,2),...
                boundary_vertices(:,3));
                warning(warnState);
                if in||on
                    flag=0;
                    return;
                end
            end
            plane_test=unique(boundary_vertices(:,2));
            if size(plane_test,1)==1&&plane_test==point(1,2)
                warnState=warning('Off','MATLAB:inpolygon:ModelingWorldLower');
                [in,on]=inpolygon(point(1,1),point(1,3),boundary_vertices(:,1),...
                boundary_vertices(:,3));
                warning(warnState);
                if in||on
                    flag=0;
                    return;
                end
            end
            plane_test=unique(boundary_vertices(:,3));
            if size(plane_test,1)==1&&plane_test==point(1,3)
                warnState=warning('Off','MATLAB:inpolygon:ModelingWorldLower');
                [in,on]=inpolygon(point(1,1),point(1,2),boundary_vertices(:,1),...
                boundary_vertices(:,2));
                warning(warnState);
                if in||on
                    flag=0;
                    return;
                end
            end
        end
    end














    for k=1:size(centroid,1)

        check=AABB(point,[vert1(k,:);vert2(k,:);vert3(k,:)]);
        if~check
            flag=1;
            continue;
        end

        temp_det=[vert1(k,:);vert2(k,:);vert3(k,:);point];
        check_step1=det([temp_det.';[1,1,1,1]]);

        if abs(check_step1)<1

            edge1=vert2(k,:)-vert1(k,:);
            edge2=vert3(k,:)-vert2(k,:);
            edge3=vert1(k,:)-vert3(k,:);
            proj=projection(vert1(k,:),vert2(k,:),vert3(k,:),point);
            dest0=centroid(k,:);
            dir01=(dest0-proj);
            check1=segment_segment(proj,dir01,vert1(k,:),edge1);
            check2=segment_segment(proj,dir01,vert2(k,:),edge2);
            check3=segment_segment(proj,dir01,vert3(k,:),edge3);
            if(check1==0&&check2==0&&check3==0)
                flag=0;
                return;
            end

            if numel(find([check1,check2,check3]==true))==1
                if(check1&&em.internal.isCollinear(point,vert1(k,:),vert2(k,:)))||...
                    (check2&&em.internal.isCollinear(point,vert2(k,:),vert3(k,:)))||...
                    (check3&&em.internal.isCollinear(point,vert3(k,:),vert1(k,:)))
                    flag=0;
                    return;
                end
            end
        end
    end
end

function[pm]=pminpmax(p)










    pm=[min(p,[],2),max(p,[],2)];
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



    if check3b
        equality_check=(point1(check3b,:)+...
        (repmat(t(check3b),1,size(vector1(check3b,:),2)).*vector1(check3b,:)))...
        -(point2(check3b,:)+(repmat(u(check3b),1,size(vector2(check3b,:),2)).*vector2(check3b,:)));


        if find(abs(sqrt(sum(dot(equality_check,equality_check,2),2)))<1e-12)

            Intersection=1;
        end
    end
end

function[proj]=projection(P1,P2,P3,P4)












    plane_normal=cross(P2-P1,P3-P1,2);

    plane_vector_magnitude=sqrt(dot(plane_normal,plane_normal,2));

    plane_vector_unit=plane_normal/plane_vector_magnitude;

    proj=P4-(dot(P4-P1,plane_vector_unit,2)*plane_vector_unit);

end

function check=AABB(point,p_element)












    pref=pminpmax(p_element');
    check=(point(1,1)>=pref(1,1)&point(1,1)<=pref(1,2))&...
    (point(1,2)>=pref(2,1)&point(1,2)<=pref(2,2))&...
    (point(1,3)>=pref(3,1)&point(1,3)<=pref(3,2));
end