function sh_fixed_displ_pump_motor_callback(modelName)








    h=get_param(modelName,'ModelWorkSpace');



    if isempty(h.getVariable('newTestBlockName'))
        if any(regexp(modelName,'pump'))
            blockName=sprintf([modelName,'/','Fixed-Displacement\nPump']);
        else
            blockName=sprintf([modelName,'/','Fixed-Displacement\nMotor']);
        end
    else
        blockName=[modelName,'/',h.getVariable('newTestBlockName')];
    end


    flowRateUnit=get_param([modelName,'/Units'],'flowRateUnit');
    powerUnit=get_param([modelName,'/Units'],'powerUnit');









    modelOrigConfigSet=getActiveConfigSet(modelName);
    modelConfigSets=getConfigSets(modelName);
    if any(strcmp('TestModelPumpMotorConfigSet',modelConfigSets))
        indx=strcmp('TestModelPumpMotorConfigSet',modelConfigSets);
        TestConfigSet=modelConfigSets{indx};
        setActiveConfigSet(modelName,TestConfigSet);
    else
        configSet=sh.internal.mask.TestModelPumpMotorConfigSet;
        configSetName=configSet.get_param('Name');
        attachConfigSet(modelName,configSet);
        setActiveConfigSet(modelName,configSetName);
    end


    lossFlag=get_param(blockName,'loss_spec');

    switch lossFlag

    case '1'
        parameterBlk=[modelName,'/Analytical parameterization'];


        dpVecDisp=eval(get_param(parameterBlk,'dpVec'));
        dpVecUnitAnalytic=get_param(blockName,'pr_nominal_unit');
        dpVecAnalytic=value(simscape.Value(dpVecDisp,dpVecUnitAnalytic),'Pa');

        omegaVecDisp=eval(get_param(parameterBlk,'omegaVec'));
        omegaVecUnitAnalytic=get_param(blockName,'w_nominal_unit');
        omegaVecAnalytic=value(simscape.Value(omegaVecDisp,omegaVecUnitAnalytic),'rad/s');

        dpVec=dpVecAnalytic(:);
        dpVecUnit=dpVecUnitAnalytic;
        omegaVec=omegaVecAnalytic(:);
        omegaVecUnit=omegaVecUnitAnalytic;


    case '2'

        dpVecDisp=eval(get_param(blockName,'p_diff_eff_TLU'));
        dpEffVecUnit=get_param(blockName,'p_diff_eff_TLU_unit');
        dpEffVec=value(simscape.Value(dpVecDisp,dpEffVecUnit),'Pa');

        omegaVecDisp=eval(get_param(blockName,'omega_eff_TLU'));
        omegaEffVecUnit=get_param(blockName,'omega_eff_TLU_unit');
        omegaEffVec=value(simscape.Value(omegaVecDisp,omegaEffVecUnit),'rad/s');


        volEffTLU=eval(get_param(blockName,'vol_eff_TLU'));
        mechEffTLU=eval(get_param(blockName,'mech_eff_TLU'));

        m=length(dpEffVec);

        figure('Name',blockName)
        legendInfo=cell(1,m);

        hAx1=subplot(2,1,1);
        hAx2=subplot(2,1,2);

        for i=1:m

            plot(hAx1,omegaVecDisp,volEffTLU(i,:),'-o');
            hold(hAx1,'on')
            plot(hAx2,omegaVecDisp,mechEffTLU(i,:),'-x');
            hold(hAx2,'on')
            legendInfo{i}=['p = ',num2str(dpVecDisp(i)),' (',dpEffVecUnit,')'];
        end

        xlabel(hAx1,['Angular speed',' (',omegaEffVecUnit,')'])
        ylabel(hAx1,'Volumetric efficiency')
        legend(hAx1,legendInfo);
        xlabel(hAx2,['Angular speed',' (',omegaEffVecUnit,')'])
        ylabel(hAx2,'Mechanical efficiency')
        legend(hAx2,legendInfo);
        grid(hAx1,'on')
        grid(hAx2,'on')
        hold(hAx1,'off')
        hold(hAx2,'off')

        dpVec=dpEffVec;
        dpVecUnit=dpEffVecUnit;
        omegaVec=omegaEffVec;
        omegaVecUnit=omegaEffVecUnit;


    case '3'

        dpVecDisp=eval(get_param(blockName,'p_diff_loss_TLU'));
        dpLossVecUnit=get_param(blockName,'p_diff_loss_TLU_unit');
        dpLossVec=value(simscape.Value(dpVecDisp,dpLossVecUnit),'Pa');

        omegaVecDisp=eval(get_param(blockName,'omega_loss_TLU'));
        omegaLossVecUnit=get_param(blockName,'omega_loss_TLU_unit');
        omegaLossVec=value(simscape.Value(omegaVecDisp,omegaLossVecUnit),'rad/s');


        volLossTLU=eval(get_param(blockName,'vol_loss_TLU'));
        volLossTLUUnit=get_param(blockName,'vol_loss_TLU_unit');
        mechLossTLU=eval(get_param(blockName,'mech_loss_TLU'));
        mechLossTLUUnit=get_param(blockName,'mech_loss_TLU_unit');

        m=length(dpLossVec);

        figure('Name',blockName)
        legendInfo=cell(1,m);
        hAx1=subplot(2,1,1);
        hAx2=subplot(2,1,2);

        for i=1:m
            plot(hAx1,omegaVecDisp,volLossTLU(i,:),'-o');
            hold(hAx1,'on')
            plot(hAx2,omegaVecDisp,mechLossTLU(i,:),'-x');
            hold(hAx2,'on')
            legendInfo{i}=['p = ',num2str(dpVecDisp(i)),' (',dpLossVecUnit,')'];
        end

        xlabel(hAx1,['Angular speed',' (',omegaLossVecUnit,')'])
        ylabel(hAx1,['Volumetric Loss',' (',volLossTLUUnit,')'])
        legend(hAx1,legendInfo);
        xlabel(hAx2,['Angular speed',' (',omegaLossVecUnit,')'])
        ylabel(hAx2,['Mechanical Loss',' (',mechLossTLUUnit,')'])
        legend(hAx2,legendInfo);
        grid(hAx1,'on')
        hold(hAx1,'off')
        grid(hAx2,'on')
        hold(hAx2,'off')

        dpVec=dpLossVec;
        dpVecUnit=dpLossVecUnit;
        omegaVec=omegaLossVec;
        omegaVecUnit=omegaLossVecUnit;

    end


    dpDuration=ones(1,length(dpVec));
    set_param([modelName,'/Hydraulic harness/Pressure'],'y_init',num2str(dpVec(1)))
    set_param([modelName,'/Hydraulic harness/Pressure'],'offset','0')
    set_param([modelName,'/Hydraulic harness/Pressure'],'sig_type','3')
    set_param([modelName,'/Hydraulic harness/Pressure'],'durations',mat2str(dpDuration))
    set_param([modelName,'/Hydraulic harness/Pressure'],'y_start',mat2str(dpVec(:)'))

    omegaDuration=length(dpVec)*ones(1,length(omegaVec));
    set_param([modelName,'/Mechanical harness/Velocity'],'y_init',num2str(omegaVec(1)))
    set_param([modelName,'/Mechanical harness/Velocity'],'offset','0')
    set_param([modelName,'/Mechanical harness/Velocity'],'sig_type','3')
    set_param([modelName,'/Mechanical harness/Velocity'],'durations',mat2str(omegaDuration))
    set_param([modelName,'/Mechanical harness/Velocity'],'y_start',mat2str(omegaVec(:)'))


    set_param([modelName,sprintf('/Mechanical harness/PS-Simulink\nConverter')],'Unit','N*m')
    set_param([modelName,sprintf('/Mechanical harness/PS-Simulink\nConverter1')],'Unit',omegaVecUnit)

    set_param([modelName,sprintf('/Hydraulic harness/PS-Simulink\nConverter')],'Unit',flowRateUnit)
    set_param([modelName,sprintf('/Hydraulic harness/PS-Simulink\nConverter1')],'Unit',dpVecUnit)

    m=length(dpVec);
    n=length(omegaVec);
    simTime=m*n;


    localSolver=[modelName,sprintf('/Solver\nConfiguration')];
    set_param(localSolver,'UseLocalSolver','on')
    set_param(localSolver,'LocalSolverSampleTime','1')

    outputs=sim(modelName,'StopTime',num2str(simTime));
    simResults=get(outputs,'yout');

    hFigure=figure('Name',blockName);
    set(hFigure,'Units','normalized');
    positionFigure=get(hFigure,'position');
    positionFigure(2)=0.15;
    positionFigure(4)=positionFigure(4)*1.15^3;
    set(hFigure,'position',positionFigure);

    hAx1=subplot(3,1,1);
    hAx2=subplot(3,1,2);
    hAx3=subplot(3,1,3);

    legendInfo=cell(1,n);

    for i=1:n
        idxStart=(i-1)*m+1;
        idxEnd=i*m;

        flowRate=simResults(idxStart:idxEnd,2);
        torque=simResults(idxStart:idxEnd,1);
        omega_simscape=simscape.Value(omegaVec(i),omegaVecUnit);
        torque_simscape=simscape.Value(torque,'N*m');

        powerMech=value(torque_simscape.*omega_simscape,powerUnit);

        powerHyd=value(simscape.Value(flowRate(:),flowRateUnit).*simscape.Value(dpVec(:),'Pa'),powerUnit);

        powerRatio=abs(powerMech./powerHyd);

        hAx1=subplot(3,1,1);
        plot(hAx1,dpVecDisp,flowRate,'-o');
        hold(hAx1,'on')

        hAx2=subplot(3,1,2);
        plot(hAx2,dpVecDisp,powerMech,'-x');
        hold(hAx2,'on')
        legendInfo{i}=['shaft speed = ',num2str(omegaVecDisp(i)),' (',omegaVecUnit,')'];

        hAx3=subplot(3,1,3);
        plot(hAx3,dpVecDisp,powerRatio,'-x');
        hold(hAx3,'on')
        legendInfo{i}=['shaft speed = ',num2str(omegaVecDisp(i)),' (',omegaVecUnit,')'];

    end
    grid(hAx1,'on')
    grid(hAx2,'on')
    grid(hAx3,'on')

    xlabel(hAx1,['Pressure difference ',' (',dpVecUnit,')'])
    ylabel(hAx1,['Flow rate ',' (',flowRateUnit,')'])
    legend(hAx1,legendInfo);

    xlabel(hAx2,['Pressure difference',' (',dpVecUnit,')'])
    ylabel(hAx2,['Mechanical power ',' (',powerUnit,')'],'interpreter','none')
    legend(hAx2,legendInfo);

    xlabel(hAx3,['Pressure difference',' (',dpVecUnit,')'])
    ylabel(hAx3,sprintf('Mechanical power to \n Hydraulic power ratio'))
    legend(hAx3,legendInfo);

    position=get(hAx1,'position');
    position(4)=position(4)*1.10;
    set(hAx1,'position',position);

    position=get(hAx2,'position');
    position(4)=position(4)*1.10;
    set(hAx2,'position',position);

    position=get(hAx3,'position');
    position(4)=position(4)*1.10;
    set(hAx3,'position',position);

    hold(hAx1,'off')
    hold(hAx2,'off')
    hold(hAx3,'off')


    setActiveConfigSet(modelName,modelOrigConfigSet.Name);

end
