function[expObj,rObj]=createSdoExperiment(pObj,expObj)



























    validateattributes(pObj,{'Battery.Pulse'},{'scalar'});


    if nargin<2||isempty(expObj)


        ModelName=pObj(1).Parent.ModelName;


        load_system(ModelName);


        assignin('base','Em',pObj(1).Parameters.Em);
        assignin('base','R0',pObj(1).Parameters.R0);
        assignin('base','Rx',pObj(1).Parameters.Rx);
        assignin('base','Tx',pObj(1).Parameters.Tx);
        assignin('base','SOC_LUT',pObj(1).Parameters.SOC);
        assignin('base','InitialCapVoltage',pObj(1).InitialCapVoltage);
        assignin('base','InitialChargeDeficitAh',0);
        assignin('base','CapacityAh',1);


        expObj=sdo.Experiment(ModelName);


        expObj.OutputData=Simulink.SimulationData.Signal;


        expObj.OutputData(1).Name='OutputVoltage';
        expObj.OutputData(1).BlockPath=[ModelName,'/Estimation Equivalent Circuit Battery'];
        expObj.OutputData(1).PortType='outport';
        expObj.OutputData(1).PortIndex=2;
        expObj.OutputData(1).Values=timeseries(0,0);


        expObj.OutputData(2).Name='OutputSOC';
        expObj.OutputData(2).BlockPath=[ModelName,'/Estimation Equivalent Circuit Battery'];
        expObj.OutputData(2).PortType='outport';
        expObj.OutputData(2).PortIndex=3;
        expObj.OutputData(2).Values=timeseries(0,0);


        expObj.OutputData(3).Name='OutputCapV';
        expObj.OutputData(3).BlockPath=[ModelName,'/Bus',newline,'Selector'];
        expObj.OutputData(3).PortType='outport';
        expObj.OutputData(3).PortIndex=1;
        expObj.OutputData(3).Values=timeseries(0,0);


        expObj.InputData=zeros(0,2);


        expObj.Parameters=[
        sdo.getParameterFromModel(ModelName,'Em')
        sdo.getParameterFromModel(ModelName,'R0')
        sdo.getParameterFromModel(ModelName,'Rx')
        sdo.getParameterFromModel(ModelName,'Tx')
        ];

    end





    Param=pObj.Parameters;


    t=pObj.Time;
    v=pObj.Voltage;
    c=pObj.Current;
























    expObj.OutputData(1).Values=timeseries(v,t);


    expObj.InputData=[t,c];


    expObj.Parameters(1).Value=Param.Em;
    expObj.Parameters(1).Minimum=Param.EmMin;
    expObj.Parameters(1).Maximum=Param.EmMax;
    expObj.Parameters(1).Free(:)=true;

    expObj.Parameters(2).Value=Param.R0;
    expObj.Parameters(2).Minimum=Param.R0Min;
    expObj.Parameters(2).Maximum=Param.R0Max;
    expObj.Parameters(2).Free(:)=true;

    expObj.Parameters(3).Value=Param.Rx;
    expObj.Parameters(3).Minimum=Param.RxMin;
    expObj.Parameters(3).Maximum=Param.RxMax;
    expObj.Parameters(3).Free(:)=true;

    expObj.Parameters(4).Value=Param.Tx;
    expObj.Parameters(4).Minimum=Param.TxMin;
    expObj.Parameters(4).Maximum=Param.TxMax;
    expObj.Parameters(4).Free(:)=true;


    rObj=sdo.requirements.SignalTracking(...
    'Type','==',...
    'Method','Residuals',...
    'ReferenceSignal',expObj.OutputData(1).Values,...
    'Normalize','off');







