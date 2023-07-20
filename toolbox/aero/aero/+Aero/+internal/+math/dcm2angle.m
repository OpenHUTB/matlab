function[anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=dcm2angle(dcm,S)









    switch S
    case "ZYX"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorThreeAxisRotation(dcm(1,2,:),dcm(1,1,:),-dcm(1,3,:),...
        dcm(2,3,:),dcm(3,3,:),...
        -dcm(2,1,:),dcm(2,2,:));

    case "ZYZ"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorTwoAxisRotation(dcm(3,2,:),dcm(3,1,:),dcm(3,3,:),...
        dcm(2,3,:),-dcm(1,3,:),...
        -dcm(2,1,:),dcm(2,2,:));

    case "ZXY"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorThreeAxisRotation(-dcm(2,1,:),dcm(2,2,:),dcm(2,3,:),...
        -dcm(1,3,:),dcm(3,3,:),...
        dcm(1,2,:),dcm(1,1,:));

    case "ZXZ"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorTwoAxisRotation(dcm(3,1,:),-dcm(3,2,:),dcm(3,3,:),...
        dcm(1,3,:),dcm(2,3,:),...
        dcm(1,2,:),dcm(1,1,:));

    case "YXZ"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorThreeAxisRotation(dcm(3,1,:),dcm(3,3,:),-dcm(3,2,:),...
        dcm(1,2,:),dcm(2,2,:),...
        -dcm(1,3,:),dcm(1,1,:));

    case "YXY"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorTwoAxisRotation(dcm(2,1,:),dcm(2,3,:),dcm(2,2,:),...
        dcm(1,2,:),-dcm(3,2,:),...
        -dcm(1,3,:),dcm(1,1,:));

    case "YZX"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorThreeAxisRotation(-dcm(1,3,:),dcm(1,1,:),dcm(1,2,:),...
        -dcm(3,2,:),dcm(2,2,:),...
        dcm(3,1,:),dcm(3,3,:));

    case "YZY"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorTwoAxisRotation(dcm(2,3,:),-dcm(2,1,:),dcm(2,2,:),...
        dcm(3,2,:),dcm(1,2,:),...
        dcm(3,1,:),dcm(3,3,:));

    case "XYZ"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorThreeAxisRotation(-dcm(3,2,:),dcm(3,3,:),dcm(3,1,:),...
        -dcm(2,1,:),dcm(1,1,:),...
        dcm(2,3,:),dcm(2,2,:));

    case "XYX"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorTwoAxisRotation(dcm(1,2,:),-dcm(1,3,:),dcm(1,1,:),...
        dcm(2,1,:),dcm(3,1,:),...
        dcm(2,3,:),dcm(2,2,:));

    case "XZY"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorThreeAxisRotation(dcm(2,3,:),dcm(2,2,:),-dcm(2,1,:),...
        dcm(3,1,:),dcm(1,1,:),...
        -dcm(3,2,:),dcm(3,3,:));

    case "XZX"




        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorTwoAxisRotation(dcm(1,3,:),dcm(1,2,:),dcm(1,1,:),...
        dcm(3,1,:),-dcm(2,1,:),...
        -dcm(3,2,:),dcm(3,3,:));
    end

    function[anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorThreeAxisRotation(r11,r12,r21,r31,r32,r11a,r12a)
        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorRotationAngles(r11,r12,r21,r31,r32,r11a,r12a,"three");
    end

    function[anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorTwoAxisRotation(r11,r12,r21,r31,r32,r11a,r12a)
        [anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorRotationAngles(r11,r12,r21,r31,r32,r11a,r12a,"two");
    end

    function[anglesDefault,anglesZeroR3,idxDefault,idxZeroR3]=factorRotationAngles(r11,r12,r21,r31,r32,r11a,r12a,axis)



        anglesDefault=zeros(numel(r11),3);
        anglesZeroR3=anglesDefault;

        r21(r21<-1)=-1;
        r21(r21>1)=1;
        idxZeroR3=squeeze(abs(abs(r21)-1)<eps);
        idxDefault=~idxZeroR3;


        if axis=="three"
            r2=asin(r21);
        else
            r2=acos(r21);
        end
        anglesDefault(:,2)=r2;
        anglesZeroR3(:,2)=r2;



        if any(idxDefault)
            anglesDefault(idxDefault,1)=atan2(r11(idxDefault),r12(idxDefault));
            anglesDefault(idxDefault,3)=atan2(r31(idxDefault),r32(idxDefault));
        end
        if any(idxZeroR3)
            anglesZeroR3(idxZeroR3,1)=atan2(r11a(idxZeroR3),r12a(idxZeroR3));
        end
    end
end