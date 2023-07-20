


classdef(Hidden=true)TimerServiceProxyContentWriter

    properties
CodeDesc
Writer
    end

    methods(Access=public)


        function this=TimerServiceProxyContentWriter(writer,codeDesc)
            this.Writer=writer;
            this.CodeDesc=codeDesc;
        end

        function writeFunctionDeclarations(this)

            timeResolutionFcn=[];
            timeFcn=[];
            timeTickFcn=[];
            deltaTimeFcn=[];
            deltaTimeTickFcn=[];
            interface=this.CodeDesc.getFullComponentInterface.PlatformServices.TimerService;
            for fcnIdx=1:interface.TimerFunctions.Size
                timerFcn=interface.TimerFunctions(fcnIdx);
                switch timerFcn.ServiceType
                case coder.descriptor.TimerServiceType.Resolution
                    timeResolutionFcn=coder.internal.rteproxy.FunctionWriter('extern','real_T','rteGetResolution',{'int_T tid'},[]);
                case coder.descriptor.TimerServiceType.AbsoluteTime
                    timeFcn=coder.internal.rteproxy.FunctionWriter('extern','real_T','rteGetAbsoluteTime',{'int_T tid'},[]);
                case coder.descriptor.TimerServiceType.FunctionClockTick
                    timeTickFcn=coder.internal.rteproxy.FunctionWriter('extern','uint32_T','rteGetFunctionClockTick',{'int_T tid'},[]);
                case coder.descriptor.TimerServiceType.FunctionStepSize
                    deltaTimeFcn=coder.internal.rteproxy.FunctionWriter('extern','real_T','rteGetFunctionStepSize',{'int_T tid'},[]);
                case coder.descriptor.TimerServiceType.FunctionStepTick
                    deltaTimeTickFcn=coder.internal.rteproxy.FunctionWriter('extern','uint32_T','rteGetFunctionStepTick',{'int_T tid'},[]);
                end
            end


            fcnDecls=[timeResolutionFcn,timeFcn,timeTickFcn,deltaTimeFcn,deltaTimeTickFcn];


            for fcnIdx=1:length(fcnDecls)
                fcnDecls(fcnIdx).writeFunctionDeclaration(this.Writer);
            end

        end

        function writeFunctionDefinitions(this)
            timerFcns=this.getRTEInterface;
            fcnDefs=[...
            this.getFunctionDefinition('real_T','rteGetResolution',timerFcns.Resolution),...
            this.getFunctionDefinition('real_T','rteGetAbsoluteTime',timerFcns.AbsoluteTime),...
            this.getFunctionDefinition('uint32_T','rteGetFunctionClockTick',timerFcns.FunctionClockTick),...
            this.getFunctionDefinition('real_T','rteGetFunctionStepSize',timerFcns.FunctionStepSize),...
            this.getFunctionDefinition('uint32_T','rteGetFunctionStepTick',timerFcns.FunctionStepTick)];


            this.Writer.wComment('timer services');
            for fcnIdx=1:length(fcnDefs)
                fcnDefs(fcnIdx).writeFunctionDefinition(this.Writer);
            end
        end

        function hasDuringExecMode=getHasDuringExecutionMode(this)
            hasDuringExecMode=false;
            interface=this.CodeDesc.getFullComponentInterface.PlatformServices.TimerService;
            for fcnIdx=1:interface.TimerFunctions.Size
                timerFcn=interface.TimerFunctions(fcnIdx);
                if strcmp(char(timerFcn.DataCommunicationMethod),'DuringExecution')
                    hasDuringExecMode=true;
                    return;
                end
            end
        end

    end

    methods(Access=private)


        function fcnDef=getFunctionDefinition(this,retType,fcnName,services)

            fcnDef=[];
            if~isempty(services)
                indentation=coder.internal.rteproxy.RTEProxyFileGeneratorBase.getIndentation;
                fcnBody={[indentation,'switch(tid) {']};
                for fcnIdx=1:length(services)
                    service=services(fcnIdx);
                    if strcmp(char(service.Method),'DuringExecution')
                        serviceCall=this.getDuringExecutionServiceCall(service);
                    else
                        serviceCall=[service.Prototype.Name,'()'];
                    end
                    fcnBody=[fcnBody,{[indentation,indentation,'case ',service.TID,' : return ',serviceCall,';']}];%#ok
                end
                fcnBody(end+1)={[indentation,indentation,'default: return 0;']};
                fcnBody(end+1)={[indentation,'}']};
                fcnDef=coder.internal.rteproxy.FunctionWriter([],retType,fcnName,{'int_T tid'},fcnBody);
            end

        end


        function timerInterface=getRTEInterface(this)


            timerInterface=struct('Resolution',[],...
            'AbsoluteTime',[],...
            'FunctionClockTick',[],...
            'FunctionStepSize',[],...
            'FunctionStepTick',[]);

            interface=this.CodeDesc.getFullComponentInterface.PlatformServices.TimerService;
            for fcnIdx=1:interface.TimerFunctions.Size

                timerFcn=interface.TimerFunctions(fcnIdx);

                for tid=1:timerFcn.Timing.Size
                    service=struct('TID',num2str(timerFcn.Timing(tid).TaskIndex),...
                    'Prototype',timerFcn.Prototype,...
                    'Method',timerFcn.DataCommunicationMethod);

                    switch timerFcn.ServiceType
                    case coder.descriptor.TimerServiceType.Resolution
                        timerInterface.Resolution=[timerInterface.Resolution,service];

                    case coder.descriptor.TimerServiceType.AbsoluteTime
                        timerInterface.AbsoluteTime=[timerInterface.AbsoluteTime,service];

                    case coder.descriptor.TimerServiceType.FunctionClockTick
                        timerInterface.FunctionClockTick=[timerInterface.FunctionClockTick,service];

                    case coder.descriptor.TimerServiceType.FunctionStepSize
                        timerInterface.FunctionStepSize=[timerInterface.FunctionStepSize,service];

                    case coder.descriptor.TimerServiceType.FunctionStepTick
                        timerInterface.FunctionStepTick=[timerInterface.FunctionStepTick,service];
                    end
                end
            end
        end

        function serviceCall=getDuringExecutionServiceCall(this,service)
            internalData=this.CodeDesc.getFullComponentInterface.InternalData;
            for dataIdx=1:internalData.Size
                if strcmp('RTModel',internalData(dataIdx).GraphicalName)
                    RTModelData=internalData(dataIdx);
                    break;
                end
            end
            serviceCall=[RTModelData.Implementation.Identifier,'->Timing.clockTick',service.TID];
        end

    end
end


