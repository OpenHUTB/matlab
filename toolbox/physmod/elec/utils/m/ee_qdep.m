function Qdep=ee_qdep(Vin,F1,F2,F3,F4,VJ,MG)











    if(Vin<F4);
        Qdep=VJ*(1-(1-Vin/VJ)^(1-MG))/(1-MG);
    else
        Qdep=F1+(F3*(Vin-F4)+(MG/(2*VJ))*(Vin^2-F4^2))/F2;
    end


