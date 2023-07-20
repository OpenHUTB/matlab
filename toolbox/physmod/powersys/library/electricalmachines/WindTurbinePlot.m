function WindTurbinePlot(block)








    [speed_nom,wind_base,P_wind_base,pitch_angle]=getSPSmaskvalues(block,{'speed_nom','wind_base','P_wind_base','pitch_angle'});
    [c1_c6,lambda_nom,cp_nom]=getSPSmaskvalues(block,{'c1_c6','lambda_nom','cp_nom'});


    if pitch_angle<0
        error(message('physmod:powersys:common:GreaterThanOrEqualTo',block,'Pitch angle beta used to display characteristics','0'));
    end

    c1=c1_c6(1);
    c2=c1_c6(2);
    c3=c1_c6(3);
    c4=c1_c6(4);
    c5=c1_c6(5);
    c6=c1_c6(6);

    wr_elec_pu=1e-3:0.01:1.5;
    wr_mec_pu=wr_elec_pu/speed_nom;
    wind_max=ceil((1.2/P_wind_base)^(1/3)*wind_base);
    wind_min=round(((0.1)/P_wind_base)^(1/3)*wind_base);
    wind1=wind_min:(wind_base-wind_min)/5:wind_base;
    wind2=wind_base+(wind_base-wind_min)/5:(wind_base-wind_min)/5:wind_max;
    wind_pu=[wind1,wind2]/wind_base;

    for k=1:length(wind_pu)
        for i=1:length(wr_mec_pu)
            lambda_pu=wr_mec_pu(i)/wind_pu(k);
            lambda=lambda_pu*lambda_nom;
            lambda_i=1/(1/(lambda+0.08*pitch_angle)-0.035/(pitch_angle^3+1));
            cp=c1*(c2/lambda_i-c3*pitch_angle-c4)*exp(-c5/lambda_i)+c6*lambda;
            cp_pu=cp/cp_nom;
            Pwind_pu(k,i)=wind_pu(k)^3*cp_pu*P_wind_base;%#ok<*AGROW>
        end
    end


    fig_num=figure;clf(fig_num);
    for k=1:length(wind_pu)
        plot(wr_elec_pu,Pwind_pu(k,:))
        hold on
    end

    plot([speed_nom,speed_nom,0],[0,P_wind_base,P_wind_base],'r--')
    text(speed_nom+0.01,0+0.05,sprintf('%0.4g pu',speed_nom))
    text(0.01,P_wind_base+0.05,sprintf('Max. power at base wind speed (%0.4g m/s) and beta = 0 deg',wind_base))
    for i=1:length(wind_pu)
        p_max(i)=max(Pwind_pu(i,:));
        speed(i)=wr_elec_pu(Pwind_pu(i,:)==p_max(i));
        text(speed(i),p_max(i),sprintf('%0.4g m/s',wind_pu(i)*wind_base))
    end

    plot([0,max(wr_elec_pu)],[0,0],'--')
    xlabel('Turbine speed (pu of nominal generator speed)')
    ylabel('Turbine output power (pu of nominal mechanical power)')
    title(sprintf('Turbine Power Characteristics (Pitch angle beta = %0.4g deg)',pitch_angle))
    axis([0,max(wr_elec_pu),min(Pwind_pu(1,:)),max(P_wind_base+0.1,max(wind_pu)^3*P_wind_base+0.1)])

