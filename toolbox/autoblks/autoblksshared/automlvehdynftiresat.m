function[Ftire_xs,Ftire_ys]=automlvehdynftiresat(Ftire_x,Ftire_y,Fxtire_sat,Fytire_sat,Ntire)
%#codegen




    coder.allowpcode('plain')
    theta_Ftire=atan2(Ftire_x,Ftire_y);
    Ftire_mag=Fxtire_sat.*Fytire_sat./sqrt((Fxtire_sat.*cos(theta_Ftire)).^2+(Fytire_sat.*sin(theta_Ftire)).^2);
    Ftire_x_max=Ftire_mag.*sin(theta_Ftire);
    Ftire_y_max=Ftire_mag.*cos(theta_Ftire);
    Ftire_xs=Ftire_x;
    tempInds=abs(Ftire_x)>abs(Ftire_x_max);
    Ftire_xs(tempInds)=Ftire_x_max(tempInds);
    Ftire_xs=Ftire_xs.*Ntire;
    Ftire_ys=Ftire_y;
    tempInds=abs(Ftire_y)>abs(Ftire_y_max);
    Ftire_ys(tempInds)=Ftire_y_max(tempInds);
    Ftire_ys=Ftire_ys.*Ntire;
end