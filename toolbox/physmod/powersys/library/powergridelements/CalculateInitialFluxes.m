function[InitialFlux1,InitialFlux2,InitialFlux3,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,UNITS,InitialFluxes,Base)



    Fist_valid_value=find(Saturation(:,1)>=0,1);
    Saturation=Saturation(Fist_valid_value:end,:);


    if~isequal([0,0],Saturation(1,:))
        Saturation=[0,0;Saturation];
    end


    Saturation=abs(Saturation);


    SAT=[-Saturation(size(Saturation,1):-1:2,:);Saturation(2:size(Saturation,1),:)];

    if UNITS==2
        SaturationCurrent=(SAT(:,1)*Base.Current)';
        SaturationFlux=(SAT(:,2)*Base.Flux)';
        InitialFlux1=InitialFluxes(1)*Base.Flux;
        InitialFlux2=InitialFluxes(2)*Base.Flux;
        InitialFlux3=InitialFluxes(3)*Base.Flux;
    else
        SaturationCurrent=SAT(:,1)';
        SaturationFlux=SAT(:,2)';
        InitialFlux1=InitialFluxes(1);
        InitialFlux2=InitialFluxes(2);
        InitialFlux3=InitialFluxes(3);
    end