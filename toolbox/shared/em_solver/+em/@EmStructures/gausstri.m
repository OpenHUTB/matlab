function[coeff,weights,IndexF]=gausstri(arg1,arg2)

    if(arg1==3&&arg2==2)
        coeff(:,1)=[1/2,1/2,0]'+1e-12;
        coeff(:,2)=[0,1/2,1/2]'+1e-12;
        coeff(:,3)=[1/2,0,1/2]'+1e-12;
        weights=[1/3,1/3,1/3];

    elseif(arg1==7&&arg2==5)
        a1=0.797426985353087;
        b1=0.101286507323456;
        a2=0.059715871789770;
        b2=0.470142064105115;
        coeff(:,1)=[1/3,1/3,1/3]';
        coeff(:,2)=[a1,b1,b1]';
        coeff(:,3)=[b1,a1,b1]';
        coeff(:,4)=[b1,b1,a1]';
        coeff(:,5)=[a2,b2,b2]';
        coeff(:,6)=[b2,a2,b2]';
        coeff(:,7)=[b2,b2,a2]';
        weights(1)=0.2250000;
        weights(2)=0.1259392;
        weights(3)=0.1259392;
        weights(4)=0.1259392;
        weights(5)=0.1323942;
        weights(6)=0.1323942;
        weights(7)=0.1323942;
    end
    IndexF=size(coeff,2);

end