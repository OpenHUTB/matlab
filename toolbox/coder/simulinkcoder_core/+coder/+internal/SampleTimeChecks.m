



classdef SampleTimeChecks<handle
    methods(Static,Access=public)
        function useAutoFixedStep=loc_shouldUseAutoFixedStep(blk_hdl,fixedStepVal,blkSampleTime)



            hasOnlyBaseRate=true;
            if~iscell(blkSampleTime)
                blkSampleTime={blkSampleTime};
            end
            nSampleTimes=length(blkSampleTime);
            for tsIdx=1:nSampleTimes
                ts=blkSampleTime{tsIdx};
                baseRates=[0,fixedStepVal,Inf,-1];
                if~any(ts(1)==baseRates)
                    hasOnlyBaseRate=false;
                    break;
                end
            end

            hasContinuousStates=false;



            if~hasOnlyBaseRate



                blks=find_system(blk_hdl,'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','type','block');
                if~isempty(blks)
                    contStates=get_param(blks,'CompiledNumContStates');

                    if(~isempty(contStates)&&iscell(contStates))
                        contStates=[contStates{:}];
                    end
                    hasContinuousStates=~isempty(contStates)&&any(contStates);
                end
            end

            useAutoFixedStep=~hasOnlyBaseRate&&~hasContinuousStates;
        end


        function retVal=LocalHasMixedSampleTimeSrc(inportHdl)
            retVal=false;
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            inpHO=get_param(inportHdl,'Object');
            actSrcP=inpHO.getActualSrc;

            if size(actSrcP,1)>1
                srcPortTs=get_param(actSrcP(:,1),'CompiledSampleTime');
                firstTs=srcPortTs{1};
                constTs=[inf,0];
                trigTs=[-1,-1];
                contTs=[0,0];
                for i=2:size(srcPortTs,1)
                    ts=srcPortTs{i};
                    if~all(ts==constTs)&&~all(ts==trigTs)&&~all(ts==contTs)
                        if all(firstTs==constTs)||all(firstTs==trigTs)||...
                            all(firstTs==contTs)
                            firstTs=ts;
                        elseif~all(firstTs==ts)
                            retVal=true;
                        end
                    end
                end
            end
            delete(sess);
        end









        function strPort=LocalGetSampleTimeFromDstIfConstant(strPort,inportH)
            constTs=[inf,inf];
            trigTs=[-1,-1];
            tmpTs=strPort.prm.CompiledSampleTime;
            mixedDst=false;

            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            if isequal(tmpTs,constTs)
                inportBlkH=coder.internal.slBus('LocalGetBlockForPortPrm',...
                inportH,'Handle');
                blkPortHdl=get_param(inportBlkH,'PortHandles');
                opHO=get_param(blkPortHdl.Outport(1),'Object');
                actDstP=opHO.getActualDst;
                if size(actDstP,1)>0
                    dstHandles=get_param(actDstP(:,1),'ParentHandle');
                    if size(dstHandles,1)>1
                        for i=1:size(dstHandles,1)
                            compiledSampleTimesObj=Simulink.ModelReference.Conversion.CompiledSampleTimes(dstHandles{i});
                            compiledSampleTimes=compiledSampleTimesObj.getSampleTimes();
                            if numel(compiledSampleTimes)>1
                                mixedDst=true;
                                break;
                            else
                                ts=compiledSampleTimes{1};
                                if~all(ts==constTs)&&~all(ts==trigTs)
                                    if all(tmpTs==constTs)
                                        tmpTs=ts;
                                    elseif~all(tmpTs==ts)
                                        mixedDst=true;
                                        break;
                                    end
                                end
                            end

                        end
                    else
                        compiledSampleTimesObj=Simulink.ModelReference.Conversion.CompiledSampleTimes(dstHandles);
                        compiledSampleTimes=compiledSampleTimesObj.getSampleTimes();
                        if numel(compiledSampleTimes)>1
                            mixedDst=true;
                        else
                            ts=compiledSampleTimes{1};
                            if~all(ts==constTs)&&~all(ts==trigTs)
                                tmpTs=ts;
                            end
                        end
                    end
                end
                if~mixedDst
                    strPort.prm.CompiledSampleTime=tmpTs;
                end
            end
            delete(sess);
        end




        function LocalSetSampleTime(blkH,portPrm,thisHdl)
            isDSMBlk=strcmp(get_param(blkH,'BlockType'),'DataStoreMemory');
            if~isDSMBlk

                if thisHdl.exportFcns
                    ts=[-1,0];
                else
                    ts=portPrm.CompiledSampleTime;
                end




                if(iscell(ts))

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
                if(length(ts)<2);ts(2)=0;end
                if(ts(2)<=-1);ts(2)=0;end
                if(all(ts==0));ts(1)=-1;end




                if(ts(1)==-2);ts=[0,1];end


                set_param(blkH,'SampleTime',sprintf('[%.17g %.17g]',ts(1),ts(2)))
            end
        end
    end
end
