classdef util<handle





    properties(Constant)

        TimerFilenameForDeployment='rte_timer.c';
        TimerFilenameForXIL='rte_timer.c';
        DataTransferFilename='rte_data_transfer.c';
    end

    methods(Static)

        function indentStr=getIndentation(idx)
            if nargin==0
                idx=1;
            end
            indentStr=repmat('    ',1,idx);
        end

        function displayProgressInfo(modelName,fileType,fileName)



            if get_param(modelName,'RTWVerbose')
                fprintf('%s### Writing %s file %s\n',...
                coder.internal.rte.util.getIndentation,...
                fileType,...
                fileName);
            end
        end

        function needPreInit=needPreInitDataTransForXIL(platformServices)
            needPreInit=false;
            if~isempty(platformServices)
                dataTransferService=platformServices.getServiceInterface(...
                coder.descriptor.Services.DataTransfer);
                if~isempty(dataTransferService)
                    needPreInit=dataTransferService.DataTransferElements.Size>0;
                end
            end
        end

        function[prototype,functionCall]=getPreInitDataTransXILPrototype
            functionName='xil_pre_init_data_transfer';
            prototype=sprintf('void %s(void)',functionName);
            functionCall=sprintf('%s()',functionName);
        end

        function useTimerService=getUsingTimerService(sdpTypes,model)

            if slfeature('TimingServicesInCodeGen')>0
                switch sdpTypes.PlatformType
                case coder.internal.rte.PlatformType.Function
                    useTimerService=true;
                case coder.internal.rte.PlatformType.ApplicationWithServices
                    useTimerService=strcmpi(...
                    get_param(model,'UsingTimingServicesInCodeGeneration'),'on');
                case coder.internal.rte.PlatformType.Application
                    useTimerService=false;
                case coder.internal.rte.PlatformType.Invalid
                    useTimerService=false;
                otherwise
                    assert(false,'Unexpected platform type encountered.');
                end
            else
                useTimerService=false;
            end
        end

        function needTimerService=getNeedTimerService(componentInterface)
            needTimerService=slfeature('TimingServicesInCodeGen')>0&&...
            ~isempty(componentInterface.PlatformServices)&&...
            ~isempty(componentInterface.PlatformServices.TimerService)&&...
            componentInterface.PlatformServices.TimerService.TimerFunctions.Size>0;
        end

        function activePluginNames=getActiveServices(codeDescriptor)




            activePluginNames=...
            coder.internal.rte.writeActiveServicePrototypes(codeDescriptor);
        end

        function val=getNeedTimeForTidInSILSimulation(componentInterface,tid)
            val=false;
            if coder.internal.rte.util.getNeedTimerService(componentInterface)

                interface=componentInterface.PlatformServices.TimerService;



                for fcnIdx=1:interface.TimerFunctions.Size
                    timerFcn=interface.TimerFunctions(fcnIdx);
                    if timerFcn.ServiceType~=coder.descriptor.TimerServiceType.Resolution
                        for idx=1:timerFcn.Timing.Size
                            if timerFcn.Timing(idx).TaskIndex==tid||...
                                (tid==-3&&strcmp(timerFcn.Timing(idx).TimingMode,'INHERITED'))
                                if(timerFcn.ServiceType==coder.descriptor.TimerServiceType.FunctionStepSize||...
                                    timerFcn.ServiceType==coder.descriptor.TimerServiceType.FunctionStepTick)

                                    if~strcmp(timerFcn.Timing(1).TimingMode,'PERIODIC')
                                        val=true;
                                        return;
                                    end
                                else

                                    val=true;
                                    return;
                                end
                            end
                        end
                    end
                end
            end
        end








        function isValid=isValidRootIOImplementation(port)
            if coder.internal.rte.util.isImplementationCollectionType(port)
                isValid=true;
            elseif isempty(port.Implementation)||...
                (isempty(port.Implementation.OpaqueRegion)&&...
                isempty(port.Implementation.DynamicMemory))
                isValid=false;
            elseif~rtw.connectivity.CodeInfoUtils.isa(port.Implementation,...
                'BasicAccessFunctionExpression')
                isValid=false;
            else
                isValid=true;
            end
        end

        function implementations=getImplementations(port)
            if coder.internal.rte.util.isImplementationCollectionType(port)
                implementations=port.Implementation.Elements.toArray;
            else
                implementations=port.Implementation;
            end
        end

    end

    methods(Static,Access=private)

        function isImplCollection=isImplementationCollectionType(port)
            if~isempty(port.Implementation)&&...
                rtw.connectivity.CodeInfoUtils.isa(port.Implementation,...
                'BasicAccessFunctionExpressionCollection')
                isImplCollection=true;
            else
                isImplCollection=false;
            end
        end

    end

end
