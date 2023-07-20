function[q0,FA,Ha,Ka,Da,dtha,t,errorFlag,ctrl1,sel,massNumber]=psbstginit(gentype,reg1,reg2,reg3,turb1,turb2,HA,KA,DA,ini1,ini2)






    t=100;


    tol=1e-4;

    errorFlag=0;
    ctrl1=4;
    err=0;

    switch gentype
    case 1

        err=numberOfValues(3,reg1,2);if err,errorFlag=5;end
        err=numberOfValues(2,reg2,3);if err,errorFlag=5;end
        err=numberOfValues(4,reg3,4);if err,errorFlag=5;end
        err=numberOfValues(4,turb1,5);if err,errorFlag=5;end
        err=numberOfValues(4,turb2,6);if err,errorFlag=5;end
        err=numberOfValues(1,ini1,7);if err,errorFlag=5;end

        q0=ini1(1);
        FA=turb2;FB=zeros(1,4);
        Ha=ones(1,4);Ka=Ha;Da=Ha;
        Hb=ones(1,4);Kb=Hb;Db=Hb;
        dtha=zeros(1,4);dthb=dtha;

        if abs(sum(FA)-1)>tol,errorFlag=1;end
        sel={1,[1,2],[1,2,3]};
        massNumber=0;

    case 2

        err=numberOfValues(3,reg1,2);if err,errorFlag=5;end
        err=numberOfValues(2,reg2,3);if err,errorFlag=5;end
        err=numberOfValues(4,reg3,4);if err,errorFlag=5;end
        err=numberOfValues(4,turb1,5);if err,errorFlag=5;end
        err=numberOfValues(4,turb2,6);if err,errorFlag=5;end
        err=numberOfValues(4,HA,7);if err,errorFlag=5;end
        err=numberOfValues(4,KA,8);if err,errorFlag=5;end
        err=numberOfValues(4,DA,9);if err,errorFlag=5;end
        err=numberOfValues(2,ini2,10);if err,errorFlag=5;end

        q0=ini2(1);sel1=[];sel2=[];sel3=[];
        FA=turb2;

        if abs(sum(FA)-1)>tol,errorFlag=1;end

        dth1a=ini2(2)*pi/180;
        Tta=q0.*[FA(4),sum(FA(3:4)),sum(FA(2:4)),sum(FA(1:4))];
        massNumber=0;

        for k=1:4
            if HA(k)==0&FA(k)~=0
                errorFlag=4;
                massNumber=k+1;
            end
        end

        idx1=(HA~=0);idx2=(FA~=0);
        sit=idx1(1)+idx1(2)*2+idx1(3)*4+idx1(4)*8;

        switch sit
        case 0
            errorFlag=3;
        case 1
            ctrl1=1;sel1=1;
            Ha=[HA(sel1),1,1,1];
            Ka=[KA(sel1),1,1,1];
            Da=[DA(sel1),1,1,1];
        case 2
            ctrl1=1;sel1=2;
            Ha=[HA(sel1),1,1,1];
            Ka=[KA(sel1),1,1,1];
            Da=[DA(sel1),1,1,1];
        case 3
            ctrl1=2;sel2=[1,2];
            Ha=[HA(sel2),1,1];
            Ka=[KA(sel2),1,1];
            Da=[DA(sel2),1,1];
        case 4
            ctrl1=1;sel1=1;
            Ha=[HA(sel1),1,1,1];
            Ka=[KA(sel1),1,1,1];
            Da=[DA(sel1),1,1,1];
        case 5
            ctrl1=2;sel2=[1,3];
            Ha=[HA(sel2),1,1];
            Ka=[KA(sel2),1,1];
            Da=[DA(sel2),1,1];
        case 6
            ctrl1=2;sel2=[2,3];
            Ha=[HA(sel2),1,1];
            Ka=[KA(sel2),1,1];
            Da=[DA(sel2),1,1];
        case 7
            ctrl1=3;sel3=[1,2,3];
            Ha=[HA(sel3),1];
            Ka=[KA(sel3),1];
            Da=[DA(sel3),1];
        case 8
            ctrl1=1;sel1=4;
            Ha=[HA(sel1),1,1,1];
            Ka=[KA(sel1),1,1,1];
            Da=[DA(sel1),1,1,1];
        case 9
            ctrl1=2;sel2=[1,4];
            Ha=[HA(sel2),1,1];
            Ka=[KA(sel2),1,1];
            Da=[DA(sel2),1,1];
        case 10
            ctrl1=2;sel2=[2,4];
            Ha=[HA(sel2),1,1];
            Ka=[KA(sel2),1,1];
            Da=[DA(sel2),1,1];
        case 11
            ctrl1=3;sel3=[1,2,4];
            Ha=[HA(sel3),1];
            Ka=[KA(sel3),1];
            Da=[DA(sel3),1];
        case 12
            ctrl1=2;sel2=[3,4];
            Ha=[HA(sel2),1,1];
            Ka=[KA(sel2),1,1];
            Da=[DA(sel2),1,1];
        case 13
            ctrl1=3;sel3=[1,3,4];
            Ha=[HA(sel3),1];
            Ka=[KA(sel3),1];
            Da=[DA(sel3),1];
        case 14
            ctrl1=3;sel3=[2,3,4];
            Ha=[HA(sel3),1];
            Ka=[KA(sel3),1];
            Da=[DA(sel3),1];
        case 15
            ctrl1=4;
            Ha=HA;Ka=KA;Da=DA;
        end

        if isempty(sel1),sel1=1;end
        if isempty(sel2),sel2=[1,2];end
        if isempty(sel3),sel3=[1,2,3];end

        sel{1}=sel1;sel{2}=sel2;sel{3}=sel3;



        dtheta_gen=ini2(2)*pi/180;
        T_gen=ini2(1);
        dtha=zeros(1,4);

        for n=1:ctrl1
            if n==1
                dtha(n)=dtheta_gen+T_gen/KA(1);
            else
                Tshaft=T_gen*(1-sum(turb2(1:n-1)));
                dtha(n)=dtha(n-1)+Tshaft/KA(n);
            end
        end

    end

    switch errorFlag
    case 1
        Erreur.message='Torque fractions total is not 1 p.u.';
        Erreur.identifier='SpecializedPowerSystems:SteamTurbineBlock:BadParameters';
        psberror(Erreur.message,Erreur.identifier,'NoUiwait');
    case 3
        Erreur.message='You requested the multi-mass shaft but set all mass inertia constants to zero. Please use the single-mass option.';
        Erreur.identifier='SpecializedPowerSystems:SteamTurbineBlock:BadParameters';
        psberror(Erreur.message,Erreur.identifier,'NoUiwait');
    case 4
        message=['Inconsistent mass inertias and power fractions. Mass #',...
        num2str(massNumber),' has inertia set to zero but the ',...
        'corresponding torque fraction is not zero.'];
        Erreur.message=message;
        Erreur.identifier='SpecializedPowerSystems:SteamTurbineBlock:BadParameters';
        psberror(Erreur.message,Erreur.identifier,'NoUiwait');
    end

    function err=numberOfValues(qty,in,nb)
        if length(in)~=qty
            message=['Parameters error: input argument #',num2str(nb),' should be',...
            ' a 1 by ',num2str(qty),' vector.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:SteamTurbineBlock:BadParameters';
            psberror(Erreur.message,Erreur.identifier,'NoUiwait');
            err=1;
        else
            err=0;
        end
