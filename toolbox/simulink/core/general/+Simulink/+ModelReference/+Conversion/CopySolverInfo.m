




classdef CopySolverInfo<handle
    properties(SetAccess=private,GetAccess=private)
CopySubsystem
    end

    methods(Access=public)
        function this=CopySolverInfo(subsys,modelName,isCopyContent)
            Simulink.ModelReference.Conversion.CopySolverInfo.exec(subsys,modelName,isCopyContent);
        end
    end

    methods(Static,Access=public)
        function[ts,ssRate]=getCompileSampleTimes(subsys,isCopyContent)
            ts=get_param(subsys,'CompiledSampleTime');
            if iscell(ts)



                ts=ts(~cellfun(@(currentSampleTime)isinf(currentSampleTime(1)),ts));
                if(numel(ts)==1)
                    ts=cell2mat(ts);
                end
            end

            if iscell(ts)
                ssRate=ts{1};
            else
                ssRate=ts;
            end



            if~isCopyContent
                ph=get_param(subsys,'PortHandles');
                inportTs=Simulink.ModelReference.Conversion.Utilities.cellify(get_param(ph.Inport,'CompiledSampleTime'));
                N=numel(inportTs);
                for idx=1:N
                    currentRate=inportTs{idx};



                    if~iscell(currentRate)
                        currentRate={currentRate};
                    end

                    numST=length(currentRate);
                    for compIdx=1:numST
                        if((currentRate{compIdx}(1)>0)&&(currentRate{compIdx}(1)<ssRate(1)))
                            ssRate=currentRate{compIdx};
                        end
                    end
                end
            end
        end

        function useFixedStepSolverWithSpecifiedFixedStep(modelRef,ts,forcefullySet)
            set_param(modelRef,'SolverType','Fixed-Step');
            tsStr=rtw.connectivity.CodeInfoUtils.double2str(ts(1));
            if forcefullySet||(strcmp(get_param(modelRef,'FixedStep'),'auto')&&~strcmp(tsStr,'auto'))
                set_param(modelRef,'FixedStep',tsStr);
            end

            if strcmp(get_param(modelRef,'SampleTimeConstraint'),'Specified')
                set_param(modelRef,'SampleTimeConstraint','Unconstrained');
            end
        end
    end

    methods(Static,Access=private)
        function exec(subsys,modelRef,isCopyContent)


            [ts,ssRate]=Simulink.ModelReference.Conversion.CopySolverInfo.getCompileSampleTimes(subsys,isCopyContent);
            assert((length(ts)==2)||iscell(ts));
            isSingleRate=~iscell(ts)&&~isinf(ts(1));
            useSpecifiedSampleTime=false;
            istriggered=isequal(ts,[-1,-1]);
            ssType=Simulink.SubsystemType(subsys);
            if~istriggered
                isSupportedSystem=...
                ssType.isAtomicSubsystem||ssType.isTriggeredSubsystem||...
                ssType.isEnabledSubsystem||ssType.isEnabledAndTriggeredSubsystem;
                if isSupportedSystem
                    if(isSingleRate&&(ts(2)==0))
                        useSpecifiedSampleTime=Simulink.ModelReference.Conversion.CopySolverInfo.isUsedSpecifiedSampleTime(subsys,ts);
                    end
                elseif ssType.isFunctionCallSubsystem

                    findOpts=horzcat({'SearchDepth',1},Simulink.ModelReference.Conversion.Utilities.BasicFindOptions,{'BlockType','TriggerPort'});
                    trigPort=find_system(subsys,findOpts{:});
                    trigType=get_param(trigPort,'SampleTimeType');
                    if strcmp(trigType,'triggered')
                        istriggered=true;
                    elseif(isSingleRate&&(ts(2)==0))
                        useSpecifiedSampleTime=true;
                    end
                elseif ssType.isIteratorSubsystem||ssType.isVirtualSubsystem
                    if(isSingleRate&&(ts(2)==0))
                        useSpecifiedSampleTime=Simulink.ModelReference.Conversion.CopySolverInfo.isUsedSpecifiedSampleTime(subsys,ts);
                    end
                else
                    assert(false,'Unsupported subsystem type: %s\n',ssType.getType);
                end
            end


            if useSpecifiedSampleTime
                forcefullySet=true;
                Simulink.ModelReference.Conversion.CopySolverInfo.useFixedStepSolverWithSpecifiedFixedStep(modelRef,ssRate,forcefullySet);
            elseif istriggered
                Simulink.ModelReference.Conversion.CopySolverInfo.useGenericFixedStepSolver(modelRef);
                set_param(modelRef,'SampleTimeConstraint','STIndependent');
            else




                if strcmpi(get_param(modelRef,'SolverType'),'Fixed-Step')
                    if Simulink.ModelReference.Conversion.CopySolverInfo.hasContinuousSampleTime(ts)
                        Simulink.ModelReference.Conversion.CopySolverInfo.useTopModelFixedStepSolver(subsys,modelRef);
                    elseif isSingleRate&&(ts(1)~=0)&&(ts(2)==0)
                        Simulink.ModelReference.Conversion.CopySolverInfo.useFixedStepSolverWithSpecifiedFixedStep(modelRef,ssRate,false);
                    else
                        Simulink.ModelReference.Conversion.CopySolverInfo.useGenericFixedStepSolver(modelRef);
                    end
                elseif isSingleRate&&(ts(1)~=0)&&(ts(2)==0)
                    Simulink.ModelReference.Conversion.CopySolverInfo.useFixedStepSolverWithSpecifiedFixedStep(modelRef,ssRate,true);
                end
            end



            if ssType.isTriggeredSubsystem
                set_param(modelRef,'PropagateVarSize','During execution');
            end
        end


        function useGenericFixedStepSolver(modelRef)
            set_param(modelRef,'SolverType','Fixed-Step');
            set_param(modelRef,'FixedStep','auto');


            if strcmpi(get_param(modelRef,'SampleTimeConstraint'),'Specified')
                set_param(modelRef,'SampleTimeConstraint','Unconstrained');
            end
        end

        function useTopModelFixedStepSolver(subsys,modelRef)
            set_param(modelRef,'SolverType','Fixed-Step');
            fixedStepStr=get_param(bdroot(subsys),'FixedStep');
            set_param(modelRef,'FixedStep',fixedStepStr);
        end

        function status=isUsedSpecifiedSampleTime(subsys,ts)





            ssUserSpecifiedSamp=get_param(subsys,'SystemSampleTime');
            ssUserTs=str2double(ssUserSpecifiedSamp);
            if~isnan(ssUserTs)&&(ssUserTs(1)~=-1)
                assert(isequal(ts(1),ssUserTs(1)));


                status=true;
            else
                status=false;
            end
        end
    end

    methods(Static,Access=public)
        function status=hasContinuousSampleTime(ts)
            if iscell(ts)
                status=any(cellfun(@(t)all(t==[0,0]),ts));
            else
                status=all(ts==[0,0]);
            end
        end
    end
end
