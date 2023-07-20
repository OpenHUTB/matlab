function vdyncheckrackpinion(TrckWdth,StrgArmLngth,RckCsLngth,TieRodLngth,D)



    c=TieRodLngth+StrgArmLngth;
    a=abs(0.5*(TrckWdth-RckCsLngth));
    b=D;
    if a>=c

        if TrckWdth>RckCsLngth
            TrckWidthPref=2*c+RckCsLngth;
            error(message('vdynblks:vdynSteeringParamCheck:invalidRP','TrckWdth',num2str(TrckWidthPref)));
        else
            RckCsLngthPref=2*c+TrckWdth;
            error(message('vdynblks:vdynSteeringParamCheck:invalidRP','RckCsLngth',num2str(RckCsLngthPref)));
        end
    end

    if(a^2+b^2)>=c^2
        DPref=sqrt(c^2-a^2);
        error(message('vdynblks:vdynSteeringParamCheck:invalidRP','D',num2str(DPref)));
    end
end
