function[AngLft,AngRght,Ratio]=vdynrackpinion(AngIn,TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D,PnnRadius)



    deltaP=AngIn*PnnRadius;
    beta0=RackPinion(TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D,0);
    AngLft=-RackPinion(TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D,deltaP)+beta0;
    AngRght=RackPinion(TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D,-deltaP)-beta0;
    Ratio=AngIn/(0.5*(AngLft+AngRght));
end
function beta=RackPinion(TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D,deltaP)
    l1=0.5*(TrckWdth-RckCsLngth)-deltaP;
    l2square=l1^2+D^2;
    beta=0.5*pi-atan2(D,l1)-acos((StrgArmLngth^2+l2square-TieRodLngth^2)/(2*StrgArmLngth*sqrt(l2square)));
end
