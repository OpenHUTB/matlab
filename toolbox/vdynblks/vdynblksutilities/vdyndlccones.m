function[LPos,RPos,LNames,RNames]=vdyndlccones(dlcType,vehW,Xoffset,YOffset,R)





    coneOffset=0.185/2;
    switch dlcType
    case '3888-1'
        laneOffset=-(3.5-(vehW*1.1+.25)/2)-(vehW*1.2+.25)/2;
        sectionLengths=[15,30,25,25,15,15];
        conesPerSection=3;
        xLPositions=Xoffset+[(0:conesPerSection-1).*sectionLengths(1)./(conesPerSection-1),sectionLengths(1)+sectionLengths(2)+(0:conesPerSection-1).*sectionLengths(3)./(conesPerSection-1),sectionLengths(1)+sectionLengths(2)+sectionLengths(3)+sectionLengths(4)+(0:conesPerSection*2-2).*(sum(sectionLengths(5:6)))./(conesPerSection.*2-2)];
        centerLine=YOffset+[0,0,0,laneOffset.*ones(1,3),-((vehW*1.3+.25)-(vehW*1.1+.25))./2.*ones(1,5)];
        yLPositions=centerLine-(vehW.*[1.1,1.1,1.1,1.2,1.2,1.2,1.3*ones(1,5)]+.25)./2-coneOffset;
        yRPositions=centerLine+(vehW.*[1.1,1.1,1.1,1.2,1.2,1.2,1.3*ones(1,5)]+.25)./2+coneOffset;
        LPos=[xLPositions',yLPositions',zeros(length(yLPositions),1)];
        RPos=[xLPositions',yRPositions',zeros(length(yLPositions),1)];
        LNames=['a,','b,','c,','d,','e,','f,','g,','h,','i,','j,','k'];
        RNames=['a'',','b'',','c'',','d'',','e'',','f'',','g'',','h'',','i'',','j'',','k'''];

    case '3888-2'
        conesPerSection=5;
        laneOffset=-(1.1*vehW+.25)./2-1-(vehW+1)/2;
        sectionLengths=[12,13.5,11,12.5,12];
        xLPositions=Xoffset+[(0:conesPerSection-1).*sectionLengths(1)./(conesPerSection-1),sectionLengths(1)+sectionLengths(2)+(0:conesPerSection-1).*sectionLengths(3)./(conesPerSection-1),sectionLengths(1)+sectionLengths(2)+sectionLengths(3)+sectionLengths(4)+(0:conesPerSection-1).*sectionLengths(5)./(conesPerSection-1)];
        centerLine=YOffset+[zeros(1,5),laneOffset.*ones(1,5),-(max((vehW*1.3+.25),3)-(vehW*1.1+.25))./2.*ones(1,5)];
        yLPositions=centerLine-([vehW.*1.1*ones(1,5)+.25,vehW.*ones(1,5)+1,max(vehW.*1.3*ones(1,5)+.25,3)])./2-coneOffset;
        yRPositions=centerLine+([vehW.*1.1*ones(1,5)+.25,vehW.*ones(1,5)+1,max(vehW.*1.3+.25,3).*ones(1,5)])./2+coneOffset;
        LPos=[xLPositions',yLPositions',zeros(length(yLPositions),1)];
        RPos=[xLPositions',yRPositions',zeros(length(yLPositions),1)];
        LNames=['a,','b,','c,','d,','e,','f,','g,','h,','i,','j,','k,','l,','m,','n,','o'];
        RNames=['a'',','b'',','c'',','d'',','e'',','f'',','g'',','h'',','i'',','j'',','k'',','l'',','m'',','n'',','o'''];

    case 'Constant Radius'
        NCones=180;
        thetavec=deg2rad(linspace(0,360-360/NCones,NCones));
        xLPositions=Xoffset+(R+vehW).*sin(thetavec);
        yLPositions=YOffset+(R+vehW).*cos(thetavec)+R;
        xRPositions=Xoffset+(R-vehW).*sin(thetavec);
        yRPositions=YOffset+(R-vehW).*cos(thetavec)+R;
        LNames=[];
        RNames=[];
        for idx=1:NCones
            LNames=[LNames,sprintf('Cone%d, ',idx)];
            RNames=[RNames,sprintf('Cone%d, ',NCones+idx)];
        end
        LNames=LNames(1:end-2);
        RNames=RNames(1:end-2);
        LPos=[xLPositions',yLPositions',zeros(length(yLPositions),1)];
        RPos=[xRPositions',yRPositions',zeros(length(yLPositions),1)];
    end


end