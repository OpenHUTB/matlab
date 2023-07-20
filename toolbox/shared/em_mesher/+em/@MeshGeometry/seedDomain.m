function[pseed,order]=seedDomain(p,numpts)


    edgeLengths=abs(diff(p'));
    eLx=edgeLengths(edgeLengths(:,1)>0,1);
    eLy=edgeLengths(edgeLengths(:,2)>0,2);
    eLz=edgeLengths(edgeLengths(:,3)>0,3);

    plimits=findlimits(p);
    min_x=plimits(1,1);
    max_x=plimits(2,1);
    min_y=plimits(1,2);
    max_y=plimits(2,2);
    min_z=plimits(1,3);
    max_z=plimits(2,3);

    if abs(min_x-max_x)<1e-14
        order=[2,3,1];
        minEdgeLength_y=min(eLy);
        maxEdgeLength_y=max(eLy);
        minEdgeLength_z=min(eLz);
        maxEdgeLength_z=max(eLz);
        minEdgeLength=min(minEdgeLength_y,minEdgeLength_z);
        maxEdgeLength=max(maxEdgeLength_y,maxEdgeLength_z);
    elseif abs(min_y-max_y)<1e-14
        order=[1,3,2];
        minEdgeLength_x=min(eLx);
        maxEdgeLength_x=max(eLx);
        minEdgeLength_z=min(eLz);
        maxEdgeLength_z=max(eLz);
        minEdgeLength=min(minEdgeLength_x,minEdgeLength_z);
        maxEdgeLength=max(maxEdgeLength_x,maxEdgeLength_z);
    else
        order=[1,2,3];
        minEdgeLength_x=min(eLx);
        maxEdgeLength_x=max(eLx);
        minEdgeLength_y=min(eLy);
        maxEdgeLength_y=max(eLy);
        minEdgeLength=min(minEdgeLength_x,minEdgeLength_y);
        maxEdgeLength=max(maxEdgeLength_x,maxEdgeLength_y);
    end


    regions=findregions(plimits(1,order(1)),plimits(2,order(1)),minEdgeLength,maxEdgeLength,4);


    if isempty(numpts)
        numpoints=[40,5,5,40];
    else
        numpoints=numpts;
    end

    seed=23;
    rng(seed);

    p1=rand(2,numpoints(1));
    p1(1,:)=regions(1,1)+(regions(2,1)-regions(1,1)).*p1(1,:);

    rng(seed);
    p2=rand(2,numpoints(2));
    p2(1,:)=regions(1,2)+(regions(2,2)-regions(1,2)).*p2(1,:);

    rng(seed);
    p3=rand(2,numpoints(2));
    p3(1,:)=regions(1,3)+(regions(2,3)-regions(1,3)).*p3(1,:);

    rng(seed);
    p4=rand(2,numpoints(1));
    p4(1,:)=regions(1,4)+(regions(2,4)-regions(1,4)).*p4(1,:);


    if isequal(order,[2,3,1])
        p1(2,:)=min_z+(max_z-min_z).*p1(2,:);
        p2(2,:)=min_z+(max_z-min_z).*p2(2,:);
        p3(2,:)=min_z+(max_z-min_z).*p3(2,:);
        p4(2,:)=min_z+(max_z-min_z).*p4(2,:);
        ptemp=[p1,p2,p3,p4];
        pdomain=[min_x.*ones(1,size(ptemp,2));ptemp(1,:);ptemp(2,:)];
    elseif isequal(order,[1,3,2])
        p1(2,:)=min_z+(max_z-min_z).*p1(2,:);
        p2(2,:)=min_z+(max_z-min_z).*p2(2,:);
        p3(2,:)=min_z+(max_z-min_z).*p3(2,:);
        p4(2,:)=min_z+(max_z-min_z).*p4(2,:);
        ptemp=[p1,p2,p3,p4];
        pdomain=[ptemp(1,:);min_y.*ones(1,size(ptemp,2));ptemp(2,:)];
    else
        p1(2,:)=min_y+(max_y-min_y).*p1(2,:);
        p2(2,:)=min_y+(max_y-min_y).*p2(2,:);
        p3(2,:)=min_y+(max_y-min_y).*p3(2,:);
        p4(2,:)=min_y+(max_y-min_y).*p4(2,:);
        ptemp=[p1,p2,p3,p4];
        pdomain=[ptemp(1,:);ptemp(2,:);min_z.*ones(1,size(ptemp,2))];
    end

    pseed=[p,pdomain];

end

function regions=findregions(min_x,max_x,elenmin,elenmax,numRegions)

    elrange=linspace(elenmin,elenmax,numRegions);
    el=exp(elrange);%#ok<NASGU>

    center_x=(max_x+min_x)/2;





    min_1=min_x+(elenmin);
    d1=5*elenmin;
    max_1=min_1+d1;


    min_2=max_1;
    max_2=center_x;



    max_4=max_x-(elenmin);
    d4=5*elenmin;
    min_4=max_4-d4;


    min_3=center_x;
    max_3=max_4;

    regions=[min_1,min_2,min_3,min_4;max_1,max_2,max_3,max_4];


end

function plimits=findlimits(p)


    min_x=min(p(1,:));
    max_x=max(p(1,:));

    min_y=min(p(2,:));
    max_y=max(p(2,:));

    min_z=min(p(3,:));
    max_z=max(p(3,:));

    plimits=[min_x,min_y,min_z;max_x,max_y,max_z];

end