



function info=collectTimerServiceInfoForSIL(this,platformServices)

    timerInterface=platformServices.getServiceInterface(...
    coder.descriptor.Services.Timer);
    defaultBaseRes=timerInterface.DefaultBaseTimeResolution;



    preStepInfo=containers.Map('KeyType','uint32','ValueType','any');
    serviceInfoVect=[];
    needTime0Data=false;
    for fcnIdx=1:timerInterface.TimerFunctions.Size
        timerFcn=timerInterface.TimerFunctions(fcnIdx);
        dataIC='';
        needTime0=false;
        switch timerFcn.ServiceType
        case coder.descriptor.TimerServiceType.Resolution
            dataIC=num2str(defaultBaseRes);

        case coder.descriptor.TimerServiceType.AbsoluteTime

            dataIC='0.0';
            needTime0=true;

        case coder.descriptor.TimerServiceType.FunctionClockTick

            dataIC='0';
            needTime0=true;


        case coder.descriptor.TimerServiceType.FunctionStepSize

            assert(timerFcn.Timing.Size==1);

            if strcmp(timerFcn.Timing(1).TimingMode,'PERIODIC')

                dataIC=num2str(timerFcn.Timing(1).SamplePeriod);
            else

                dataIC='0.0';
                needTime0=true;
            end

        case coder.descriptor.TimerServiceType.FunctionStepTick

            assert(timerFcn.Timing.Size==1);

            if strcmp(timerFcn.Timing(1).TimingMode,'PERIODIC')

                tick=floor((timerFcn.Timing(1).SamplePeriod/defaultBaseRes)+0.5);
                dataIC=num2str(tick);
            else

                dataIC='0';
                needTime0=true;
            end
        end
        internalData=struct('Name',[timerFcn.Prototype.Name,'_data'],...
        'Type',timerFcn.Prototype.Return.Type.Identifier,...
        'IC',dataIC);
        serviceInfo=struct('Name',timerFcn.Prototype.Name,...
        'Data',internalData);
        TimerService=struct('ServiceType',timerFcn.ServiceType,...
        'PublicGetFcn',this.constructGetImpl(serviceInfo),...
        'PrivateSetFcn',this.constructSetImpl(serviceInfo),...
        'PrivateGetFcn',[],...
        'PrivateGetPtrFcn',[],...
        'InternalData',internalData);
        serviceInfoVect=[serviceInfoVect,TimerService];%#ok

        if needTime0
            for idx=1:timerFcn.Timing.Size
                tid=timerFcn.Timing(idx).TaskIndex;
                preStepFcn=struct('ServiceType',timerFcn.ServiceType,...
                'PrivateSetFcn',this.constructSetImpl(serviceInfo),...
                'needPrevTime',(timerFcn.ServiceType==coder.descriptor.TimerServiceType.FunctionStepSize||...
                timerFcn.ServiceType==coder.descriptor.TimerServiceType.FunctionStepTick));

                if isKey(preStepInfo,tid)
                    preStepInfo(tid)=[preStepInfo(tid),{preStepFcn}];
                else
                    preStepInfo(tid)={preStepFcn};
                end
            end
        end

        needTime0Data=needTime0Data||needTime0;
    end

    preStepFcns=[];
    preStepTids=keys(preStepInfo);
    for preStepIdx=1:length(preStepTids)
        tid=preStepTids{preStepIdx};
        preStepFcns=[preStepFcns,this.constructPreStepFcnForSIL(preStepInfo(tid),tid,defaultBaseRes)];%#ok
    end

    if needTime0Data
        typeTime='real_T';
        timeData=struct('Name',[this.InternalTime0FcnName,'_data'],...
        'Type',typeTime,...
        'IC','0.0');
        serviceInfo=struct('Name',this.InternalTime0FcnName,...
        'Data',timeData);
        TimerService=struct('ServiceType',coder.descriptor.TimerServiceType.AbsoluteTime,...
        'PublicGetFcn',[],...
        'PrivateSetFcn',[],...
        'PrivateGetFcn',[],...
        'PrivateGetPtrFcn',this.constructGetPtrImpl(serviceInfo),...
        'InternalData',timeData);
        serviceInfoVect=[serviceInfoVect,TimerService];
    end
    info=struct('ServiceFcn',serviceInfoVect,'PreStepFcn',preStepFcns);
end


