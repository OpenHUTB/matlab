function[phi,phi_wrapped]=aeroblkphiWrap(phi)






%#codegen

    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    fphi=abs(phi);
    slat=1.0;
    phi_wrapped=false;

    if fphi>pi
        if(phi<-pi)
            slat=-1.0;
        end

        phi=slat*(mod(fphi+pi,2*pi)-pi);
        fphi=abs(phi);
    end

    pi_2=pi/2.0;

    if fphi>pi_2
        phi_wrapped=true;
        if(phi>pi_2)
            phi=pi_2-(fphi-pi_2);
        end
        if(phi<-pi_2)
            phi=-1*(pi_2-(fphi-pi_2));
        end
    end
end
