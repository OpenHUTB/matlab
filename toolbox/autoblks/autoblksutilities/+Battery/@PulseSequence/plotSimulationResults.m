function h=plotSimulationResults(psObj,Param)





























    for psIdx=1:numel(psObj)





        if nargin<2
            Param=psObj(psIdx).Parameters(end);
        end


        ModelName=psObj(psIdx).ModelName;





        load_system(ModelName);


        OptimParamMgr=Battery.DistributedParameterManager();
        OptimParamMgr.setParameter('Em',Param.Em);
        OptimParamMgr.setParameter('R0',Param.R0);
        OptimParamMgr.setParameter('Rx',Param.Rx);
        OptimParamMgr.setParameter('Tx',Param.Tx);
        OptimParamMgr.assignParametersInBaseWorkspace();


        NonOptimParamMgr=Battery.DistributedParameterManager();
        NonOptimParamMgr.setParameter('CapacityAh',psObj(psIdx).CapacityAh);







        Exp=sdo.Experiment(ModelName);




        Exp.OutputData=Simulink.SimulationData.Signal;


        Exp.OutputData(1).Name='OutputVoltage';
        Exp.OutputData(1).BlockPath=[ModelName,'/Estimation Equivalent Circuit Battery'];
        Exp.OutputData(1).PortType='outport';
        Exp.OutputData(1).PortIndex=2;


        Exp.OutputData(2).Name='OutputSOC';
        Exp.OutputData(2).BlockPath=[ModelName,'/Estimation Equivalent Circuit Battery'];
        Exp.OutputData(2).PortType='outport';
        Exp.OutputData(2).PortIndex=3;


        Exp.OutputData(3).Name='OutputCapV';
        Exp.OutputData(3).BlockPath=[ModelName,'/Bus',newline,'Selector'];
        Exp.OutputData(3).PortType='outport';
        Exp.OutputData(3).PortIndex=1;





        TimeData=psObj(psIdx).Data(:,1);
        VoltageData=psObj(psIdx).Data(:,2);
        CurrentData=psObj(psIdx).Data(:,3);



        InitialChargeDeficitAh=psObj(psIdx).Pulse(1).InitialChargeDeficitAh;
        InitialCapVoltage=psObj(psIdx).Pulse(1).InitialCapVoltage;





        Exp.OutputData(1).Values=timeseries(VoltageData,TimeData);



        for dIdx=2:numel(Exp.OutputData)
            Exp.OutputData(dIdx).Values=timeseries(0,0);
        end


        Exp.InputData=[TimeData,CurrentData];


        NonOptimParamMgr.setParameter('SOC_LUT',Param.SOC);
        NonOptimParamMgr.setParameter('InitialChargeDeficitAh',InitialChargeDeficitAh);
        NonOptimParamMgr.setParameter('Em',Param.Em);
        NonOptimParamMgr.setParameter('InitialCapVoltage',InitialCapVoltage);


        NonOptimParamMgr.assignParametersInBaseWorkspace();







        ParamList=sdo.getParameterFromModel(ModelName,'Em');
        ParamList(2)=sdo.getParameterFromModel(ModelName,'R0');
        ParamList(3)=sdo.getParameterFromModel(ModelName,'Rx');
        ParamList(4)=sdo.getParameterFromModel(ModelName,'Tx');


        ParamList(1).Value=Param.Em;
        ParamList(2).Value=Param.R0;
        ParamList(3).Value=Param.Rx;
        ParamList(4).Value=Param.Tx;




        Exp=Exp.setEstimatedValues(ParamList);
        SimLog=getSimLog(Exp);














        VoltageSignal=find(SimLog,'OutputVoltage');
        FigName=psObj(psIdx).MetaData.Name;
        if isempty(FigName)
            FigName='Pulse Sequence';
        end
        h=figure('Name',FigName,'NumberTitle','off');
        set(h,'WindowStyle','docked');
        clf;



        h2=subplot(4,1,1:3);
        plot(TimeData/3600,VoltageData,'-r.');
        hold on;
        plot(VoltageSignal.Values.Time/3600,VoltageSignal.Values.Data,...
        '-b','LineWidth',2);
        ylabel('Volts')
        xlabel('Time (hours)');
        legend('data','simulation','Location','Best');
        title(psObj(psIdx).MetaData.Name);




        sim_residuals=getVoltageResiduals(VoltageSignal,Exp);

        h4=subplot(4,1,4);
        mean_residual=mean(abs(sim_residuals))*1000;
        max_residual=max(abs(sim_residuals))*1000;

        residualLimits=[-max_residual,max_residual];
        plot(TimeData(TimeData<max(VoltageSignal.Values.Time))/3600,sim_residuals(TimeData<max(VoltageSignal.Values.Time))*1000,'m');
        line(get(gca,'XLim'),[0,0],'Color','k');
        ylabel('mV')
        xlabel(h4,getString(message('autoblks:autoblkUtilMisc:labelX2',num2str(mean_residual),num2str(max_residual))));
        ylim(h4,residualLimits);




        linkaxes([h2,h4],'x');











        drawnow;

    end



    function SimLog=getSimLog(Exp)

        Simulator=Exp.createSimulator();
        Simulator=sim(Simulator);

        SimLog=find(Simulator.LoggedData,...
        get_param(Exp.ModelName,'SignalLoggingName'));



        function VoltageError=getVoltageResiduals(VoltageSignal,Exp)

            r=sdo.requirements.SignalTracking;
            r.Type='==';
            r.Method='Residuals';
            r.Normalize='off';

            VoltageError=evalRequirement(r,...
            VoltageSignal.Values,Exp.OutputData(strcmp({Exp.OutputData.Name},'OutputVoltage')).Values);
