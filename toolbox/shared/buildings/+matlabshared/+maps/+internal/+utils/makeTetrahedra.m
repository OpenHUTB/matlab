function[P,T]=makeTetrahedra(p,t,h,h0)

















    if nargin<4
        h0=0;
    end

    pbottom=p;
    pbottom(:,3)=h0;
    tbottom=t;
    ptop=p;
    ptop(:,3)=h;
    ttop=tbottom+max(size(p));
    tprism=[tbottom,ttop];
    pprism=[pbottom;ptop];

    mask=[1,2,3,4,5,6;2,3,1,5,6,4;3,1,2,6,4,5;4,6,5,1,3,2;5,4,6,2,1,3;6,5,4,3,2,1];
    T=[];
    for i=1:size(tprism,1)
        prism=tprism(i,:);
        minVertex=find(prism==min(prism));
        indirectionVec=mask(minVertex,:);
        rotatedPrism=prism(indirectionVec);


        if min(rotatedPrism(2),rotatedPrism(6))<min(rotatedPrism(3),rotatedPrism(5))
            T=[T;rotatedPrism(1),rotatedPrism(2),rotatedPrism(3),rotatedPrism(6);
            rotatedPrism(1),rotatedPrism(2),rotatedPrism(6),rotatedPrism(5);
            rotatedPrism(1),rotatedPrism(5),rotatedPrism(6),rotatedPrism(4)];

        elseif min(rotatedPrism(3),rotatedPrism(5))<min(rotatedPrism(2),rotatedPrism(6))
            T=[T;rotatedPrism(1),rotatedPrism(2),rotatedPrism(3),rotatedPrism(5);
            rotatedPrism(1),rotatedPrism(5),rotatedPrism(3),rotatedPrism(6);
            rotatedPrism(1),rotatedPrism(5),rotatedPrism(6),rotatedPrism(4)];
        end

    end


    P=pprism;
