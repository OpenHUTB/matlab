


classdef SampleTimeUtils<handle
    methods(Static,Access=private)
        function isBEPwithBusObjects=isaBusElementPortAssociatedBusObject(blkHandle)
            isBEPwithBusObjects=(strcmpi(get_param(blkHandle,'BlockType'),'Inport')||strcmpi(get_param(blkHandle,'BlockType'),'Outport'))&&...
            Simulink.ModelReference.Conversion.isBusElementPort(blkHandle)&&startsWith(get_param(blkHandle,'OutDataTypeStr'),'Bus:');
        end
    end
    methods(Static,Access=private)
        function setSampleTimeImplRCB(portInfo,dstBlock,isTriggeredModel)
            assert(~strcmp(get_param(dstBlock,'BlockType'),'DataStoreMemory'));
            if isTriggeredModel
                ts=[-1,0];
            else
                ts=portInfo.SampleTime;
                if iscell(ts)

                    if(length(ts)==2&&...
                        isequal(ts{1},[0,0]))
                        ts=ts{2};

                    elseif(length(ts)==2&&...
                        isequal(ts{2}(1),inf))
                        ts=ts{1};

                    elseif(length(ts)==3&&...
                        isequal(ts{1},[0,0])&&...
                        isequal(ts{3}(1),inf))
                        ts=ts{2};

                    else
                        ts=[-1,0];
                    end
                end

                ts(ts==inf)=-1;
                if(length(ts)<2)
                    ts(2)=0;
                end
                if(ts(2)<=-1)
                    ts(2)=0;
                end
                if(all(ts==0))
                    ts(1)=-1;
                end
                if(ts(1)==-2)
                    ts=[0,1];
                end
            end
            set_param(dstBlock,'SampleTime',sprintf('[%.17g %.17g]',ts(1),ts(2)));
        end
    end
    methods(Static,Access=public)
        function setSampleTime(portInfo,srcBlock,dstBlock,isTriggeredModel,isRightClickBuild)








            if(~portInfo.IsTriggered&&...
                ~iscell(portInfo.SampleTime)&&...
                ~(length(portInfo.SampleTime)==1&&isinf(portInfo.SampleTime))&&...
                ~(length(portInfo.SampleTime)==2&&portInfo.SampleTime(2)<0))

                isTriggerPort=strcmpi(get_param(srcBlock(1),'BlockType'),'TriggerPort');
                isEnablePort=strcmpi(get_param(srcBlock(1),'BlockType'),'EnablePort');
                isResettablePort=strcmpi(get_param(srcBlock(1),'BlockType'),'ResetPort');




                if isTriggerPort
                    sampleTimeParameter='TriggerSignalSampleTime';
                else
                    sampleTimeParameter='SampleTime';
                end





                if(isTriggerPort||isEnablePort||isResettablePort||...
                    strcmpi(get_param(srcBlock(1),'BlockType'),'Goto')||...
                    isequal(get_param(srcBlock(1),'HasInheritedSampleTime'),'on'))




                    isBEPwithBusObj=Simulink.ModelReference.Conversion.SampleTimeUtils.isaBusElementPortAssociatedBusObject(dstBlock);





                    if isTriggerPort||isEnablePort||isResettablePort||...
                        ~isBEPwithBusObj&&~isTriggeredModel

                        if slfeature('RightClickBuild')&&isRightClickBuild
                            Simulink.ModelReference.Conversion.SampleTimeUtils.setSampleTimeImplRCB(portInfo,dstBlock,isTriggeredModel);
                        else
                            set_param(dstBlock,sampleTimeParameter,portInfo.SampleTimeStr);
                        end
                    end




                    if isTriggerPort&&~strcmpi(get_param(dstBlock,'BlockType'),'Inport')&&strcmpi(get_param(dstBlock,'TriggerType'),'function-call')&&...
                        strcmpi(get_param(dstBlock,'SampleTimeType'),'periodic')
                        set_param(dstBlock,'SampleTime',portInfo.SampleTimeStr);
                    end
                else
                    set_param(dstBlock,sampleTimeParameter,get_param(srcBlock,'SampleTime'));
                end
            end
        end


        function status=isSampleTimeIndependent(model,isExportFcn)
            if isExportFcn
                status=true;
            elseif strcmp(get_param(model,'SolverType'),'Fixed-step')
                status=strcmp(get_param(model,'SampleTimeConstraint'),'STIndependent');
            else
                status=false;
            end
        end


        function setSampleTimeForPort(model,portInfo,origBlk,newBlk,isExportedFcn,isRightClickBuild)
            isSampleTimeIndependent=Simulink.ModelReference.Conversion.SampleTimeUtils.isSampleTimeIndependent(...
            model,isExportedFcn);
            isTriggeredModel=~isempty(find_system(model,'SearchDepth','1','BlockType','TriggerPort'));
            if~isSampleTimeIndependent
                Simulink.ModelReference.Conversion.SampleTimeUtils.setSampleTime(portInfo,origBlk,newBlk,isTriggeredModel,isRightClickBuild);
            end
        end




        function[mixed,ts]=getSampleTimeFromBus(dataAccessor,busName,ts)






            mixed=false;
            busObj=Simulink.ModelReference.Conversion.getBusObjectFromName(busName,true,dataAccessor);

            numberOfBusElements=length(busObj.Elements);
            for idx=1:numberOfBusElements
                busElm=busObj.Elements(idx);
                dtypeIsABus=~isempty(Simulink.ModelReference.Conversion.getBusObjectFromName(busElm.DataType,false,dataAccessor));

                if dtypeIsABus
                    [mixed,ts]=Simulink.ModelReference.Conversion.SampleTimeUtils.getSampleTimeFromBus(dataAccessor,busElm.DataType,ts);
                    if mixed
                        return;
                    end
                else




                    if ts==-1
                        ts=busElm.SampleTime;
                    else

                        if~isequal(busElm.SampleTime,-1)&&~isequal(busElm.SampleTime,ts)
                            mixed=true;
                            ts=-1;
                            return;
                        end
                    end
                end
            end
        end

    end
end

