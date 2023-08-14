function pt=maketriangle(S,NW)


    if nargin==1
        NW=0;
    end

    if length(S)==1

        height=sind(60)*S(1);



        yOffset=NW*(height/S(1));

        pt1=[0,yOffset,0];
        pt2=[S(1)/2,-height,0];
        pt3=[-S(1)/2,-height,0];

    elseif length(S)==2


        height=sqrt(S(2)^2-S(1)^2/4);

        yOffset=NW*(height/S(1));
        pt1=[0,yOffset,0];
        pt2=[S(1)/2,-height,0];
        pt3=[-S(1)/2,-height,0];

    elseif length(S)==3


        s=(S(1)+S(2)+S(3))/2;
        area=sqrt(s*(s-S(1))*(s-S(2))*(s-S(3)));
        height=(2*area)/S(1);

        yOffset=NW*(height/S(1));
        pt1=[0,yOffset,0];
        pt2=[(sqrt(S(3)^2-height^2)),-height,0];
        pt3=[-(sqrt(S(2)^2-height^2)),-height,0];

    end
    pt=[pt1;pt2;pt3];
    [cx,cy]=centroid(polyshape(pt(:,1:2)));
    pt=em.internal.translateshape(pt',-1*[cx,cy,0]);