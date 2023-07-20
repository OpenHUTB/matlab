function[t,v,tRes,vRes]=getSimulationOutputs(expObj,simObj,rObj)














    simObj.LoggingInfo.Signals(:)=[];

    simObj=expObj.createSimulator(simObj);


    eTime=expObj.InputData(end,1);
    pID=paramid.BlockParameter('StopTime',expObj.ModelName);
    p=param.String(pID,mat2str(eTime));
    simObj.Parameters=vertcat(simObj.Parameters,p);


    simObj=simObj.sim();


    SignalLoggingName=get_param(expObj.ModelName,'SignalLoggingName');
    SimLog=find(simObj.LoggedData,SignalLoggingName);
    VoltageSignal=find(SimLog,'OutputVoltage');
    t=VoltageSignal.Values.Time;
    v=VoltageSignal.Values.Data;


    if nargin<3
        rObj=sdo.requirements.SignalTracking(...
        'Type','==',...
        'Method','Residuals',...
        'Normalize','off');
        vRes=rObj.evalRequirement(VoltageSignal.Values,expObj.OutputData(1).Values);
    else
        vRes=rObj.evalRequirement(VoltageSignal.Values);
    end
    tRes=expObj.OutputData(1).Values.Time;



    tRes(numel(vRes)+1:end)=[];
