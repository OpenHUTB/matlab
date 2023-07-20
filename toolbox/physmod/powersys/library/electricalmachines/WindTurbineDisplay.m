function WindTurbineDisplay(block)







    block=getfullname(block);
    [power_A,power_B,power_C,power_D,wind_point_C]=getSPSmaskvalues(block,{'power_A','power_B','power_C','power_D','wind_point_C'});
    [speed_A,speed_B,speed_C,speed_D]=getSPSmaskvalues(block,{'speed_A','speed_B','speed_C','speed_D'});
    lambda_nom=str2num(get_param([block,'/Wind Turbine'],'lambda_nom'));
    cp_nom=str2num(get_param([block,'/Wind Turbine'],'cp_nom'));













    c1_c6=str2num(get_param([block,'/Wind Turbine'],'c1_c6'));
    c1=c1_c6(1);c2=c1_c6(2);c3=c1_c6(3);c4=c1_c6(4);c5=c1_c6(5);c6=c1_c6(6);
    beta=0;
    fig_num=figure;
    clf(fig_num);
    wr_elec_pu=1e-9:((speed_D+0.1)-1e-9)/100:(speed_D+0.1);
    wr_mec_pu=wr_elec_pu/speed_C;

    wind_max=ceil((1.2/power_C)^(1/3)*wind_point_C);
    wind_min=round(((power_B/3)/power_C)^(1/3)*wind_point_C);
    wind1=wind_min:(wind_point_C-wind_min)/5:wind_point_C;
    wind2=wind_point_C+(wind_point_C-wind_min)/5:(wind_point_C-wind_min)/5:wind_max+(wind_point_C-wind_min)/5;
    wind_pu=[wind1,wind2]/wind_point_C;

    for k=1:length(wind_pu)
        for i=1:length(wr_mec_pu);
            lambda_pu=wr_mec_pu(i)/wind_pu(k);
            lambda=lambda_pu*lambda_nom;
            lambda_i=1/(1/(lambda+0.08*beta)-0.035/(beta^3+1));
            cp=c1*(c2/lambda_i-c3*beta-c4)*exp(-c5/lambda_i)+c6*lambda;
            cp_pu=cp/cp_nom;
            Pwind_pu(k,i)=wind_pu(k)^3*cp_pu*power_C;
        end
    end
    for k=1:length(wind_pu)
        plot(wr_elec_pu,Pwind_pu(k,:))
        hold on
    end

    speed_B_C=speed_B/speed_C:(speed_C-speed_B)/speed_C/100:speed_C/speed_C;

    plot([0,max(wr_elec_pu)],[0,0],'--')
    plot([0,speed_A],[0,power_A],'LineWidth',2,'Color',[1,0,0])
    text(max(0,speed_A-0.1)+0.01,max(Pwind_pu(1,:))+0.01,sprintf('%0.4g m/s',wind_min))
    hold on
    plot([speed_A,speed_B],[power_A,power_B],'LineWidth',2,'Color',[1,0,0])
    text(speed_A,power_A-0.02,'A')
    hold on
    plot(speed_B_C*speed_C,speed_B_C.^3*power_C,'LineWidth',2,'Color',[1,0,0])
    text(speed_B-0.02,power_B,'B')
    hold on
    plot([speed_C,speed_D],[power_C,power_D],'LineWidth',2,'Color',[1,0,0])
    text(speed_C+0.01,power_C-0.03,'C')
    text(speed_C-0.1,power_C+0.02,sprintf('%0.4g m/s',wind_point_C))
    hold on
    plot([speed_D,max(wr_elec_pu)],[power_D,power_D],'LineWidth',2,'Color',[1,0,0])
    text(speed_D,power_D+0.03,'D')
    text(max(wr_elec_pu)-0.1,max(Pwind_pu(length(wind_pu),:)),sprintf('%0.4g m/s',max(wind_pu)*wind_point_C))
    plot([speed_C,speed_C,0],[0,power_C,power_C],'--')

    axis([max(0,speed_A-0.1),speed_D+0.1,-0.1,max(Pwind_pu(length(wind_pu),:))+0.05])

    xlabel('Turbine speed (pu of generator synchronous speed)')
    ylabel('Turbine output power (pu of nominal mechanical power)')
    title('Turbine Power Characteristics (Pitch angle beta = 0 deg)')