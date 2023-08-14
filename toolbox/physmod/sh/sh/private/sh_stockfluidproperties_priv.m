function fullInfo=sh_stockfluidproperties_priv


















    stockFluidNames=...
    {'skydrol_ld_4';...
    'skydrol_500_4';...
    'skydrol_5';...
    'hy_jet';...
    'f_83282';...
    'f_5606';...
    'f_87257';...
    'oil_10w';...
    'oil_30w';...
    'oil_50w';...
    'oil_sae_30';...
    'oil_sae_50';...
    'atf_dexron';...
    'iso_vg_22';...
    'iso_vg_32';...
    'iso_vg_46';...
    'brake_dot_3';...
    'brake_dot_4';...
    'brake_dot_5';...
    'gasoline';...
    'diesel_fuel';...
    'jet_fuel';...
    'water_glycol';...
    'water';...
    };

    persistent INFO;

    if isempty(INFO)
        prefix='l_fluid_';
        INFO=struct;
        for i=1:length(stockFluidNames)
            id=stockFluidNames{i};
            INFO.(id)=l_createinfofields(feval([prefix,id]));
        end
    end
    fullInfo=INFO;

end

function f=l_createinfofields(info)








    f=struct('name',info.name,...
    'prop',@l_compute_fluid_properties,...
    'plot',@l_plot_fluid_properties);

    function[viscosity,density,bulk_m]=...
        l_compute_fluid_properties(fluid_temp)









        if(fluid_temp<=info.pour_point)
            error('SimHydraulics:stock_fluid_properties:wrongLowTemp',...
            'Specified fluid temperature is below pour point');
        elseif(fluid_temp>250)
            error('SimHydraulics:stock_fluid_properties:wrongHighTemp',...
            'Specified fluid temperature is above approximation range');
        end




        [viscosity,density,bulk_m]=info.group(fluid_temp,info);




        viscosity=viscosity*pm_unit('cSt','m^2/s','linear');
        bulk_m=bulk_m*pm_unit('bar','Pa','linear');
        density=density*1;
    end

    function l_plot_fluid_properties



        t=linspace(info.pour_point+0.1,250-0.1);
        n=length(t);

        viscosity=zeros(n,1);
        bulk_m=zeros(n,1);
        density=zeros(n,1);

        for i=1:n
            [viscosity(i),density(i),bulk_m(i)]=f.prop(t(i));
        end

        title=['Simscape Fluids Fluid Properties: ',info.name];
        fig=figure('Name',title,...
        'NumberTitle','off');

        position=get(fig,'Position');
        position(2)=position(2)-(700-position(4));
        position(3)=500;
        position(4)=700;
        set(fig,'Position',position);
        a=subplot(3,1,1);
        plot(a,t,viscosity);
        set(get(a,'XLabel'),'String','Temperature (^oC)');
        set(get(a,'YLabel'),'String','Viscosity (m^2/s)');
        a=subplot(3,1,2);
        plot(a,t,density);
        set(get(a,'XLabel'),'String','Temperature (^oC)');
        set(get(a,'YLabel'),'String','Density (kg/m^3)');
        a=subplot(3,1,3);
        plot(a,t,bulk_m);
        set(get(a,'XLabel'),'String','Temperature (^oC)');
        set(get(a,'YLabel'),'String','Bulk Modulus (Pa)');
    end
end

function[viscosity,density,bulk_m]=...
    l_walther_mineral_synthetic(fluid_temp,info)




    viscosity=10^(10^(info.visc_a-info.visc_b*log10(fluid_temp+273.15)))...
    -info.visc_c;



    bulk_m=(info.bulk_ref-info.bulk_a*log(viscosity))*...
    10^(info.bulk_b*(info.temp_ref-fluid_temp));

    density=info.density_ref+info.density_a*(fluid_temp-info.temp_ref);

end

function[viscosity,density,bulk_m]=l_vogel_fuel(fluid_temp,info)




    viscosity=info.visc_a*exp(info.visc_b/(fluid_temp+273.15-info.visc_c));

    bulk_m=(info.bulk_ref+info.bulk_a*log(viscosity))*...
    10^(info.bulk_b*(info.temp_ref-fluid_temp));

    density=info.density_ref-info.density_a*(fluid_temp-info.temp_ref);

end

function[viscosity,density,bulk_m]=l_vogel_water(fluid_temp,info)




    viscosity=info.visc_a*exp(info.visc_b/(fluid_temp+273.15-info.visc_c));

    bulk_m=info.bulk_a+info.bulk_b*(fluid_temp-info.temp_ref)+...
    info.bulk_c*(fluid_temp-info.temp_ref)^2+...
    info.bulk_d*(fluid_temp-info.temp_ref)^3;


    density=info.density_ref-...
    info.density_a*(fluid_temp-info.temp_ref)-...
    info.density_b*(fluid_temp-info.temp_ref)^2;
end




















function info=l_fluid_skydrol_ld_4
    info.name='Skydrol LD-4';
    info.visc_a=7.5515;
    info.visc_b=3.0178;
    info.visc_c=0.2561;
    info.temp_ref=24;
    info.bulk_ref=1.7382e4;
    info.bulk_a=802.5;
    info.bulk_b=0.0029;
    info.bulk_c=17.25;
    info.density_ref=990;
    info.density_a=-0.7813;
    info.pour_point=-62;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_skydrol_500_4
    info.name='Skydrol 500B-4';
    info.visc_a=8.3824;
    info.visc_b=3.3518;
    info.visc_c=0.0515;
    info.temp_ref=24;
    info.bulk_ref=1.9443e4;
    info.bulk_a=1072;
    info.bulk_b=0.0032;
    info.bulk_c=15.9;
    info.density_ref=1045;
    info.density_a=-0.7889;
    info.pour_point=-62;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_skydrol_5
    info.name='Skydrol-5';
    info.visc_a=8.6352;
    info.visc_b=3.4686;
    info.visc_c=0.2028;
    info.temp_ref=24;
    info.bulk_ref=1.4548e4;
    info.bulk_a=91.8;
    info.bulk_b=0.0024;
    info.bulk_c=17.99;
    info.density_ref=974;
    info.density_a=-0.7846;
    info.pour_point=-62;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_hy_jet
    info.name='HyJet-4A';
    info.visc_a=7.9034;
    info.visc_b=3.1645;
    info.visc_c=0.2662;
    info.temp_ref=15.6;
    info.bulk_ref=1.4119e4;
    info.bulk_a=-104.36;
    info.bulk_b=0.00235;
    info.bulk_c=18.895;
    info.density_ref=1001;
    info.density_a=-0.78;
    info.pour_point=-62;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_f_83282
    info.name='Fluid MIL-F-83282';
    info.visc_a=8.410;
    info.visc_b=3.330;
    info.visc_c=0.84;
    info.temp_ref=20;
    info.bulk_ref=1.862e4;
    info.bulk_a=-164.98;
    info.bulk_b=0.00235;
    info.bulk_c=12.056;
    info.density_ref=838;
    info.density_a=-0.62;
    info.pour_point=-52;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_f_5606
    info.name='Fluid MIL-F-5606';
    info.visc_a=7.450;
    info.visc_b=2.970;
    info.visc_c=0.16;
    info.temp_ref=20;
    info.bulk_ref=1.528e4;
    info.bulk_a=-91.8;
    info.bulk_b=0.0025;
    info.bulk_c=14.5;
    info.density_ref=860;
    info.density_a=-0.63;
    info.pour_point=-52;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_f_87257
    info.name='Fluid MIL-F-87257';
    info.visc_a=11.20;
    info.visc_b=4.55;
    info.visc_c=-0.58;
    info.temp_ref=20;
    info.bulk_ref=1.860e4;
    info.bulk_a=-120;
    info.bulk_b=0.002;
    info.bulk_c=12.1;
    info.density_ref=860;
    info.density_a=-0.6796;
    info.pour_point=-62;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_oil_10w
    info.name='Oil-10W';
    info.visc_a=7.24;
    info.visc_b=2.78;
    info.visc_c=1.104;
    info.temp_ref=20;
    info.bulk_ref=1.880e4;
    info.bulk_a=-94.3;
    info.bulk_b=0.003;
    info.bulk_c=9.8;
    info.density_ref=847;
    info.density_a=-0.48;
    info.pour_point=-54;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_oil_30w
    info.name='Oil-30W';
    info.visc_a=9.12;
    info.visc_b=3.54;
    info.visc_c=0.42;
    info.temp_ref=20;
    info.bulk_ref=1.880e4;
    info.bulk_a=-192;
    info.bulk_b=0.003;
    info.bulk_c=13.74;
    info.density_ref=860;
    info.density_a=-0.5;
    info.pour_point=-43;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_oil_50w
    info.name='Oil-50W';
    info.visc_a=8.12;
    info.visc_b=3.1;
    info.visc_c=1.09;
    info.temp_ref=20;
    info.bulk_ref=1.880e4;
    info.bulk_a=-117.5;
    info.bulk_b=0.003;
    info.bulk_c=10.8;
    info.density_ref=875;
    info.density_a=-0.585;
    info.pour_point=-36;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_oil_sae_30
    info.name='Oil SAE-30';
    info.visc_a=9.08;
    info.visc_b=3.52;
    info.visc_c=-0.19;
    info.temp_ref=20;
    info.bulk_ref=1.880e4;
    info.bulk_a=-110;
    info.bulk_b=0.003;
    info.bulk_c=11.6;
    info.density_ref=890;
    info.density_a=-0.58;
    info.pour_point=-38;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_oil_sae_50
    info.name='Oil SAE-50';
    info.visc_a=7.21;
    info.visc_b=2.76;
    info.visc_c=3.19;
    info.temp_ref=20;
    info.bulk_ref=1.880e4;
    info.bulk_a=-110;
    info.bulk_b=0.003;
    info.bulk_c=11.6;
    info.density_ref=914;
    info.density_a=-0.58;
    info.pour_point=-36;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_atf_dexron
    info.name='Transmission fluid ATF (Dexron III)';
    info.visc_a=8.18;
    info.visc_b=3.20;
    info.visc_c=0.313;
    info.temp_ref=20;
    info.bulk_ref=1.628e4;
    info.bulk_a=-204.6;
    info.bulk_b=0.002;
    info.bulk_c=13.7;
    info.density_ref=878;
    info.density_a=-0.63;
    info.pour_point=-46;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_iso_vg_22
    info.name='ISO VG 22 (ESSO UNIVIS N 22)';
    info.visc_a=9.1299;
    info.visc_b=3.6068;
    info.visc_c=0.426;
    info.temp_ref=20;
    info.bulk_ref=1.5280e4;
    info.bulk_a=-103.45512;
    info.bulk_b=2.3806e-3;
    info.bulk_c=12.9895;
    info.density_ref=864;
    info.density_a=-0.569;
    info.pour_point=-48;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_iso_vg_32
    info.name='ISO VG 32 (ESSO UNIVIS N 32)';
    info.visc_a=9.0844;
    info.visc_b=3.5690;
    info.visc_c=5.6925e-2;
    info.temp_ref=20;
    info.bulk_ref=1.61e4;
    info.bulk_a=-107.0979;
    info.bulk_b=2.8036e-3;
    info.bulk_c=9.2711;
    info.density_ref=870;
    info.density_a=-0.64;
    info.pour_point=-42;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_iso_vg_46
    info.name='ISO VG 46 (ESSO UNIVIS N 46)';
    info.visc_a=9.5375;
    info.visc_b=3.7342;
    info.visc_c=-0.9172;
    info.temp_ref=20;
    info.bulk_ref=1.64e4;
    info.bulk_a=-119.5063;
    info.bulk_b=2.8037e-3;
    info.bulk_c=9.1733;
    info.density_ref=879;
    info.density_a=-0.5827;
    info.pour_point=-39;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_brake_dot_3
    info.name='Brake fluid DOT 3';
    info.visc_a=13.323;
    info.visc_b=5.4173;
    info.visc_c=0.0588;
    info.temp_ref=20;
    info.bulk_ref=1.96e4;
    info.bulk_a=-119.51;
    info.bulk_b=2.8037e-3;
    info.bulk_c=9.1733;
    info.density_ref=1036;
    info.density_a=-0.8512;
    info.pour_point=-50;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_brake_dot_4
    info.name='Brake fluid DOT 4';
    info.visc_a=14.2721;
    info.visc_b=5.8217;
    info.visc_c=0.0624;
    info.temp_ref=20;
    info.bulk_ref=1.90e4;
    info.bulk_a=-234.57;
    info.bulk_b=1.9763e-3;
    info.bulk_c=8.1254;
    info.density_ref=1062;
    info.density_a=-0.8751;
    info.pour_point=-50;
    info.group=@l_walther_mineral_synthetic;
end

function info=l_fluid_brake_dot_5
    info.name='Brake fluid DOT 5';
    info.visc_a=13.4341;
    info.visc_b=5.4780;
    info.visc_c=0.0511;
    info.temp_ref=20;
    info.bulk_ref=1.50e4;
    info.bulk_a=-164.24;
    info.bulk_b=1.546e-3;
    info.bulk_c=9.1638;
    info.density_ref=1015;
    info.density_a=-0.8367;
    info.pour_point=-50;
    info.group=@l_walther_mineral_synthetic;
end


function info=l_fluid_gasoline
    info.name='Gasoline';
    info.visc_a=4.7795e-2;
    info.visc_b=5.3586e2;
    info.visc_c=8.0904e1;
    info.temp_ref=20;
    info.bulk_ref=1.220e4;
    info.bulk_a=1130.0838;
    info.bulk_b=1.6870e-3;
    info.bulk_c=7.7730;
    info.density_ref=720;
    info.density_a=0.9376;
    info.pour_point=-52;
    info.group=@l_vogel_fuel;
end

function info=l_fluid_diesel_fuel
    info.name='Diesel fuel';
    info.visc_a=4.7203e-2;
    info.visc_b=7.9527e2;
    info.visc_c=9.6674e1;
    info.temp_ref=20;
    info.bulk_ref=1.650e4;
    info.bulk_a=4.1702e2;
    info.bulk_b=8.6899e-4;
    info.bulk_c=3.0392;
    info.density_ref=824;
    info.density_a=0.7003;
    info.pour_point=-35;
    info.group=@l_vogel_fuel;
end

function info=l_fluid_jet_fuel
    info.name='Jet fuel';
    info.visc_a=2.2465e-2;
    info.visc_b=9.8257e2;
    info.visc_c=6.2785e1;
    info.temp_ref=20;
    info.bulk_ref=1.210e4;
    info.bulk_a=1.5377e3;
    info.bulk_b=1.1939e-3;
    info.bulk_c=4.5921;
    info.density_ref=808;
    info.density_a=0.7891;
    info.pour_point=-60;
    info.group=@l_vogel_fuel;
end

function info=l_fluid_water_glycol
    info.name='Water-Glycol 60/40';
    info.visc_a=7.8309e-2;
    info.visc_b=4.6701e2;
    info.visc_c=1.8015e2;
    info.temp_ref=20;
    info.bulk_ref=2.12e4;
    info.bulk_a=2.1475e4;
    info.bulk_b=8.9260e1;
    info.bulk_c=-4.6019e-1;
    info.bulk_d=-1.3235e-4;
    info.density_ref=1080;
    info.density_a=0.58021;
    info.density_b=1.5727e-3;
    info.pour_point=-32;
    info.group=@l_vogel_water;
end

function info=l_fluid_water
    info.name='Water';
    info.visc_a=0.0374;
    info.visc_b=443.5170;
    info.visc_c=158.4127;
    info.temp_ref=1;
    info.bulk_ref=2.040e4;
    info.bulk_a=2.0424e4;
    info.bulk_b=8.7310e1;
    info.bulk_c=-8.7045e-1;
    info.bulk_d=1.7143e-3;
    info.density_ref=1000;
    info.density_a=4.4627e-2;
    info.density_b=3.7459e-3;
    info.pour_point=0;
    info.group=@l_vogel_water;
end


