function switchedCapacitanceInit(blk)






    a=str2num(get_param(blk,'a'));
    g=str2num(get_param(blk,'g'));
    b=str2num(get_param(blk,'b'));
    c=str2num(get_param(blk,'c'));
    capacitorDensity=str2num(get_param(blk,'CapacitorDensity'));
    capacitanceCoefficient=str2num(get_param(blk,'CapacitorCoefficient'));
    OSR=str2num(get_param(blk,'OSR'));
    SNR=str2num(get_param(blk,'capacitorSNR'));
    Vref=str2num(get_param(blk,'VReference'));
    Vin=str2num(get_param(blk,'VInput'));
    order_select=get_param(blk,'dsmOrder');
    order=str2num(order_select(1));
    architecture=get_param(blk,'dsmArchitecture');
    numberLevel=str2num(get_param(blk,'NumberLevels'));
    fringeValue=str2num(get_param(blk,'FringeCapacitor'));
    GridStep=str2num(get_param(blk,'GridStep'));
    tolerance=[0.02;0.025;0;0.035];
    tag1=1e5;tag2=2e5;
    fig1=findobj(groot,'Name','Delta Sigma Modulator Switched Capacitors');
    fig2=findobj(groot,'Name','Switched Capacitor Circuit');

    if~isequal(fig1,gobjects(0,0))
        close(tag1);
    elseif isequal(fig1,gobjects(0,0))
    end

    if~isequal(fig2,gobjects(0,0))
        close(tag2);
    elseif isequal(fig2,gobjects(0,0))
    end

    [numeratorA,numeratorB,numeratorC,numeratorG,denominatorA,denominatorB,...
    denominatorC,denominatorG,~,~,~,~,bType,gType]=...
    msblks.ADC.estimateCoefficient(a,b,c,g,order,architecture,tolerance(1),numberLevel,Vref);
    unitCapacitanceStage=msblks.ADC.discreteTimeCapacitor(numeratorA,denominatorA,numeratorB,...
    denominatorB,numeratorC,denominatorC,numeratorG,denominatorG,architecture,order,...
    Vref,numberLevel,OSR,Vin,capacitorDensity,capacitanceCoefficient,SNR);
    [gK,gL,gNumeratorAll,~]=msblks.ADC.estimateG(unitCapacitanceStage,numeratorG,...
    tolerance(4),order,gType);
    [~,~,bNumeratorAll]=msblks.ADC.estimateB(numeratorB,tolerance(2),bType);
    [widths,lengths,unitCapacitance,~]=...
    msblks.ADC.capacitorArea(unitCapacitanceStage,capacitorDensity,fringeValue,GridStep,tag1);
    [Area,TotalCapacitance]=msblks.ADC.sortArea(architecture,order,numberLevel,widths,lengths,numeratorA,...
    numeratorB,numeratorC,numeratorG,denominatorA,denominatorB,denominatorC,...
    gType,gK,gL,unitCapacitanceStage);
    msblks.ADC.displayCapacitance(architecture,numeratorA,numeratorB,numeratorC,numeratorG,denominatorA,...
    denominatorC,gNumeratorAll,bNumeratorAll,bType,gType,unitCapacitance,numberLevel,tag1,tag2);

end