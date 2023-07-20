



function info=collectTimerServiceInfoForNativeApplication(this,platformServices)

    timerInterface=platformServices.getServiceInterface(...
    coder.descriptor.Services.Timer);
    defaultBaseRes=timerInterface.DefaultBaseTimeResolution;



    needTick=containers.Map('KeyType','int32','ValueType','logical');
    hasTick=containers.Map('KeyType','int32','ValueType','logical');
    info=[];
    for fcnIdx=1:timerInterface.TimerFunctions.Size
        timerFcn=timerInterface.TimerFunctions(fcnIdx);
        dataIC='';
        switch timerFcn.ServiceType
        case coder.descriptor.TimerServiceType.Resolution
            dataIC=num2str(defaultBaseRes);

        case coder.descriptor.TimerServiceType.AbsoluteTime

            for idx=1:timerFcn.Timing.Size
                needTick(timerFcn.Timing(idx).TaskIndex)=true;
            end
            dataIC='0.0';

        case coder.descriptor.TimerServiceType.FunctionClockTick

            dataIC='0';
            for idx=1:timerFcn.Timing.Size
                hasTick(timerFcn.Timing(idx).TaskIndex)=true;
            end

        case coder.descriptor.TimerServiceType.FunctionStepSize

            assert(timerFcn.Timing.Size==1);

            if strcmp(timerFcn.Timing(1).TimingMode,'PERIODIC')

                dataIC=num2str(timerFcn.Timing(1).SamplePeriod);
            else

                needTick(timerFcn.Timing(1).TaskIndex)=true;
                dataIC='0.0';
            end

        case coder.descriptor.TimerServiceType.FunctionStepTick

            assert(timerFcn.Timing.Size==1);

            if strcmp(timerFcn.Timing(1).TimingMode,'PERIODIC')

                dataIC='1';
            else

                needTick(timerFcn.Timing(1).TaskIndex)=true;
                dataIC='0';
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
        info=[info,TimerService];%#ok
    end

    tidNeedTick=keys(needTick);
    for idx=1:length(tidNeedTick)
        if~isKey(hasTick,tidNeedTick(idx))
            typeTick='uint32_T';

            tickData=struct('Name',[this.InternalTickFcnName,'_',num2str(tidNeedTick{idx}),'_data'],...
            'Type',typeTick,...
            'IC','0');
            serviceInfo=struct('Name',[this.InternalTickFcnName,'_',num2str(tidNeedTick{idx})],...
            'Data',tickData);
            TimerService=struct('ServiceType',coder.descriptor.TimerServiceType.FunctionClockTick,...
            'PublicGetFcn',[],...
            'PrivateSetFcn',this.constructSetImpl(serviceInfo),...
            'PrivateGetFcn',this.constructGetImpl(serviceInfo),...
            'PrivateGetPtrFcn',[],...
            'InternalData',tickData);
            info=[info,TimerService];%#ok
        end
    end
end


