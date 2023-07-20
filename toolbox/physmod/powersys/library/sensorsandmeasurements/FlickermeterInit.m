function[f0,Tini,T1_lp,lp1_ini,LimMax1,LimMin1,b_lp,a_lp,fc_hp,hp_ini,LimMin_hp1,LimMax_hp1,k,lambda,w1,w2,w3,w4,T2_lp,Flick_max,V_G,freq,dV,fm]=FlickermeterInit(N_freq,type_volt,test_mode,V_R,Lim_1,Lim_5,type_fluc)






    if~license('test','Control_Toolbox')||isempty(ver('control'))
        error(message('physmod:powersys:common:ProductNotFound','Control System Toolbox','Digital Flickermeter'));
    end

    if(N_freq==1)
        f0=60;
    else
        f0=50;
    end


    Tini=0.3;


    if(type_volt==1)
        freq=60;
        V_G=120;
    else
        freq=50;
        V_G=230;
    end


    if(test_mode)
        f0=freq;
        V_R=V_G;
    end


    T1_lp=27.3;
    lp1_ini=V_R*sqrt(2);




    LimMax1=Lim_1;
    LimMin1=-Lim_1;


    fc_hp=0.05;
    hp_ini=-0.5;
    LimMin_hp1=-5;
    LimMax_hp1=5;

    if(f0==60)

        b_lp=[0,0,0,0,0,0,1];
        a_lp=[2.960908914038089e-015,3.018964287743599e-012,1.539078984743462e-009...
        ,4.974342636030825e-007,1.071813506905387e-004,1.464113046800272e-002...
        ,1.0];




        k=1.6357;
        lambda=2*pi*4.167375;
        w1=2*pi*9.077169;

        w2=2*pi*2.939902;
        w3=2*pi*1.394468;
        w4=2*pi*17.31512;

    else
        b_lp=[0,0,0,0,0,0,1];
        a_lp=[8.841226642775154e-015,7.512149216478187e-012,3.191434182764056e-009...
        ,8.595664075061294e-007,1.543411449943761e-004,1.756935656160328e-002...
        ,1.0];





        k=1.74802;
        lambda=2*pi*4.05981;
        w1=2*pi*9.15494;

        w2=2*pi*2.27979;
        w3=2*pi*1.22535;
        w4=2*pi*21.9;
    end


    T2_lp=0.3;


    Flick_max=Lim_5;

    switch type_fluc
    case 2
        switch type_volt
        case 1
            dV=0.321;
        case 2
            dV=0.250;
        end
    case 1
        switch type_volt
        case 1
            dV=0.253;
        case 2
            dV=0.199;
        end
    end

    fm=8.8;