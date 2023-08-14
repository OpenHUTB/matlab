function angle=aeroblkrod2angle(rod,seq)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    r1=0;
    r2=0;
    r3=0;
    th=0;
    s=0;
    cth=0;
    sth=0;
    sx=0;
    sy=0;
    sz=0;
    n=norm(rod);
    if n~=0
        th=2*atan(n);
        s=rod/n;
        cth=cos(th);
        sth=sin(th);
        sx=s(1);
        sy=s(2);
        sz=s(3);


        switch seq
        case 0
            [r1,r2,r3]=threeaxisrot(sx*sy*(1-cth)+sz*sth,...
            sx^2+(1-sx^2)*cth,sy*sth-sx*sz*(1-cth),...
            sy*sz*(1-cth)+sx*sth,sz^2+(1-sz^2)*cth);
        case 1
            [r1,r2,r3]=twoaxisrot(sy*sz*(1-cth)-sx*sth,...
            sx*sz*(1-cth)+sy*sth,sz^2+(1-sz^2)*cth,...
            sy*sz*(1-cth)+sx*sth,sy*sth-sx*sz*(1-cth));

        case 2
            [r1,r2,r3]=threeaxisrot(sz*sth-sx*sy*(1-cth),...
            sy^2+(1-sy^2)*cth,sy*sz*(1-cth)+sx*sth,...
            sy*sth-sx*sz*(1-cth),sz^2+(1-sz^2)*cth);

        case 3
            [r1,r2,r3]=twoaxisrot(sx*sz*(1-cth)+sy*sth,...
            sx*sth-sy*sz*(1-cth),sz^2+(1-sz^2)*cth,...
            sx*sz*(1-cth)-sy*sth,sy*sz*(1-cth)+sx*sth);

        case 4
            [r1,r2,r3]=threeaxisrot(sx*sz*(1-cth)+sy*sth,...
            sz^2+(1-sz^2)*cth,sx*sth-sy*sz*(1-cth),...
            sx*sy*(1-cth)+sz*sth,sy^2+(1-sy^2)*cth);

        case 5
            [r1,r2,r3]=twoaxisrot(sx*sy*(1-cth)-sz*sth,...
            sy*sz*(1-cth)+sx*sth,sy^2+(1-sy^2)*cth,...
            sx*sy*(1-cth)+sz*sth,sx*sth-sy*sz*(1-cth));

        case 6
            [r1,r2,r3]=threeaxisrot(sy*sth-sx*sz*(1-cth),...
            sx^2+(1-sx^2)*cth,sx*sy*(1-cth)+sz*sth,...
            sx*sth-sy*sz*(1-cth),sy^2+(1-sy^2)*cth);

        case 7
            [r1,r2,r3]=twoaxisrot(sy*sz*(1-cth)+sx*sth,...
            sz*sth-sx*sy*(1-cth),sy^2+(1-sy^2)*cth,...
            sy*sz*(1-cth)-sx*sth,sx*sy*(1-cth)+sz*sth);

        case 8
            [r1,r2,r3]=threeaxisrot(sx*sth-sy*sz*(1-cth),...
            sz^2+(1-sz^2)*cth,sx*sz*(1-cth)+sy*sth,...
            sz*sth-sx*sy*(1-cth),sx^2+(1-sx^2)*cth);

        case 9
            [r1,r2,r3]=twoaxisrot(sx*sy*(1-cth)+sz*sth,...
            sy*sth-sx*sz*(1-cth),sx^2+(1-sx^2)*cth,...
            sx*sy*(1-cth)-sz*sth,sx*sz*(1-cth)+sy*sth);

        case 10
            [r1,r2,r3]=threeaxisrot(sy*sz*(1-cth)+sx*sth,...
            sy^2+(1-sy^2)*cth,sz*sth-sx*sy*(1-cth),...
            sx*sz*(1-cth)+sy*sth,sx^2+(1-sx^2)*cth);

        case 11
            [r1,r2,r3]=twoaxisrot(sx*sz*(1-cth)-sy*sth,...
            sx*sy*(1-cth)+sz*sth,sx^2+(1-sx^2)*cth,...
            sx*sz*(1-cth)+sy*sth,sz*sth-sx*sy*(1-cth));
        otherwise
            [r1,r2,r3]=threeaxisrot(sx*sy*(1-cth)+sz*sth,...
            sx^2+(1-sx^2)*cth,sy*sth-sx*sz*(1-cth),...
            sy*sz*(1-cth)+sx*sth,sz^2+(1-sz^2)*cth);
        end
    end
    angle=[r1;r2;r3];
end

function[r1,r2,r3]=threeaxisrot(r11,r12,r21,r31,r32)

    r1=atan2(r11,r12);
    r21(r21<-1)=-1;
    r21(r21>1)=1;
    r2=asin(r21);
    r3=atan2(r31,r32);
end

function[r1,r2,r3]=twoaxisrot(r11,r12,r21,r31,r32)
    r1=atan2(r11,r12);
    r21(r21<-1)=-1;
    r21(r21>1)=1;
    r2=acos(r21);
    r3=atan2(r31,r32);
end
