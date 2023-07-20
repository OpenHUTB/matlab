function dcm=angle2dcm(angles,S)









    cang=cos(angles);
    sang=sin(angles);

    switch S
    case "ZYX"




        r11=cang(:,2).*cang(:,1);
        r12=cang(:,2).*sang(:,1);
        r13=-sang(:,2);
        r21=sang(:,3).*sang(:,2).*cang(:,1)-cang(:,3).*sang(:,1);
        r22=sang(:,3).*sang(:,2).*sang(:,1)+cang(:,3).*cang(:,1);
        r23=sang(:,3).*cang(:,2);
        r31=cang(:,3).*sang(:,2).*cang(:,1)+sang(:,3).*sang(:,1);
        r32=cang(:,3).*sang(:,2).*sang(:,1)-sang(:,3).*cang(:,1);
        r33=cang(:,3).*cang(:,2);

    case "ZYZ"




        r11=cang(:,1).*cang(:,3).*cang(:,2)-sang(:,1).*sang(:,3);
        r12=sang(:,1).*cang(:,3).*cang(:,2)+cang(:,1).*sang(:,3);
        r13=-sang(:,2).*cang(:,3);
        r21=-cang(:,1).*cang(:,2).*sang(:,3)-sang(:,1).*cang(:,3);
        r22=-sang(:,1).*cang(:,2).*sang(:,3)+cang(:,1).*cang(:,3);
        r23=sang(:,2).*sang(:,3);
        r31=cang(:,1).*sang(:,2);
        r32=sang(:,1).*sang(:,2);
        r33=cang(:,2);

    case "ZXY"




        r11=cang(:,3).*cang(:,1)-sang(:,2).*sang(:,3).*sang(:,1);
        r12=cang(:,3).*sang(:,1)+sang(:,2).*sang(:,3).*cang(:,1);
        r13=-sang(:,3).*cang(:,2);
        r21=-cang(:,2).*sang(:,1);
        r22=cang(:,2).*cang(:,1);
        r23=sang(:,2);
        r31=sang(:,3).*cang(:,1)+sang(:,2).*cang(:,3).*sang(:,1);
        r32=sang(:,3).*sang(:,1)-sang(:,2).*cang(:,3).*cang(:,1);
        r33=cang(:,2).*cang(:,3);

    case "ZXZ"




        r11=-sang(:,1).*cang(:,2).*sang(:,3)+cang(:,1).*cang(:,3);
        r12=cang(:,1).*cang(:,2).*sang(:,3)+sang(:,1).*cang(:,3);
        r13=sang(:,2).*sang(:,3);
        r21=-sang(:,1).*cang(:,3).*cang(:,2)-cang(:,1).*sang(:,3);
        r22=cang(:,1).*cang(:,3).*cang(:,2)-sang(:,1).*sang(:,3);
        r23=sang(:,2).*cang(:,3);
        r31=sang(:,1).*sang(:,2);
        r32=-cang(:,1).*sang(:,2);
        r33=cang(:,2);

    case "YXZ"




        r11=cang(:,1).*cang(:,3)+sang(:,2).*sang(:,1).*sang(:,3);
        r12=cang(:,2).*sang(:,3);
        r13=-sang(:,1).*cang(:,3)+sang(:,2).*cang(:,1).*sang(:,3);
        r21=-cang(:,1).*sang(:,3)+sang(:,2).*sang(:,1).*cang(:,3);
        r22=cang(:,2).*cang(:,3);
        r23=sang(:,1).*sang(:,3)+sang(:,2).*cang(:,1).*cang(:,3);
        r31=sang(:,1).*cang(:,2);
        r32=-sang(:,2);
        r33=cang(:,2).*cang(:,1);

    case "YXY"




        r11=-sang(:,1).*cang(:,2).*sang(:,3)+cang(:,1).*cang(:,3);
        r12=sang(:,2).*sang(:,3);
        r13=-cang(:,1).*cang(:,2).*sang(:,3)-sang(:,1).*cang(:,3);
        r21=sang(:,1).*sang(:,2);
        r22=cang(:,2);
        r23=cang(:,1).*sang(:,2);
        r31=sang(:,1).*cang(:,3).*cang(:,2)+cang(:,1).*sang(:,3);
        r32=-sang(:,2).*cang(:,3);
        r33=cang(:,1).*cang(:,3).*cang(:,2)-sang(:,1).*sang(:,3);

    case "YZX"




        r11=cang(:,1).*cang(:,2);
        r12=sang(:,2);
        r13=-sang(:,1).*cang(:,2);
        r21=-cang(:,3).*cang(:,1).*sang(:,2)+sang(:,3).*sang(:,1);
        r22=cang(:,2).*cang(:,3);
        r23=cang(:,3).*sang(:,1).*sang(:,2)+sang(:,3).*cang(:,1);
        r31=sang(:,3).*cang(:,1).*sang(:,2)+cang(:,3).*sang(:,1);
        r32=-sang(:,3).*cang(:,2);
        r33=-sang(:,3).*sang(:,1).*sang(:,2)+cang(:,3).*cang(:,1);

    case "YZY"




        r11=cang(:,1).*cang(:,3).*cang(:,2)-sang(:,1).*sang(:,3);
        r12=sang(:,2).*cang(:,3);
        r13=-sang(:,1).*cang(:,3).*cang(:,2)-cang(:,1).*sang(:,3);
        r21=-cang(:,1).*sang(:,2);
        r22=cang(:,2);
        r23=sang(:,1).*sang(:,2);
        r31=cang(:,1).*cang(:,2).*sang(:,3)+sang(:,1).*cang(:,3);
        r32=sang(:,2).*sang(:,3);
        r33=-sang(:,1).*cang(:,2).*sang(:,3)+cang(:,1).*cang(:,3);

    case "XYZ"




        r11=cang(:,2).*cang(:,3);
        r12=sang(:,1).*sang(:,2).*cang(:,3)+cang(:,1).*sang(:,3);
        r13=-cang(:,1).*sang(:,2).*cang(:,3)+sang(:,1).*sang(:,3);
        r21=-cang(:,2).*sang(:,3);
        r22=-sang(:,1).*sang(:,2).*sang(:,3)+cang(:,1).*cang(:,3);
        r23=cang(:,1).*sang(:,2).*sang(:,3)+sang(:,1).*cang(:,3);
        r31=sang(:,2);
        r32=-sang(:,1).*cang(:,2);
        r33=cang(:,1).*cang(:,2);

    case "XYX"




        r11=cang(:,2);
        r12=sang(:,1).*sang(:,2);
        r13=-cang(:,1).*sang(:,2);
        r21=sang(:,2).*sang(:,3);
        r22=-sang(:,1).*cang(:,2).*sang(:,3)+cang(:,1).*cang(:,3);
        r23=cang(:,1).*cang(:,2).*sang(:,3)+sang(:,1).*cang(:,3);
        r31=sang(:,2).*cang(:,3);
        r32=-sang(:,1).*cang(:,3).*cang(:,2)-cang(:,1).*sang(:,3);
        r33=cang(:,1).*cang(:,3).*cang(:,2)-sang(:,1).*sang(:,3);

    case "XZY"




        r11=cang(:,3).*cang(:,2);
        r12=cang(:,1).*cang(:,3).*sang(:,2)+sang(:,1).*sang(:,3);
        r13=sang(:,1).*cang(:,3).*sang(:,2)-cang(:,1).*sang(:,3);
        r21=-sang(:,2);
        r22=cang(:,1).*cang(:,2);
        r23=sang(:,1).*cang(:,2);
        r31=sang(:,3).*cang(:,2);
        r32=cang(:,1).*sang(:,2).*sang(:,3)-sang(:,1).*cang(:,3);
        r33=sang(:,1).*sang(:,2).*sang(:,3)+cang(:,1).*cang(:,3);

    case "XZX"




        r11=cang(:,2);
        r12=cang(:,1).*sang(:,2);
        r13=sang(:,1).*sang(:,2);
        r21=-sang(:,2).*cang(:,3);
        r22=cang(:,1).*cang(:,3).*cang(:,2)-sang(:,1).*sang(:,3);
        r23=sang(:,1).*cang(:,3).*cang(:,2)+cang(:,1).*sang(:,3);
        r31=sang(:,2).*sang(:,3);
        r32=-cang(:,1).*cang(:,2).*sang(:,3)-sang(:,1).*cang(:,3);
        r33=-sang(:,1).*cang(:,2).*sang(:,3)+cang(:,1).*cang(:,3);
    end

    a=[r11,r21,r31,r12,r22,r32,r13,r23,r33];
    b=a.';
    dcm=reshape(b,3,3,[]);

end
