classdef MultithreadingState






    enumeration
NoDataForModel
NoDataForSubsystem
Disabled
NewParent
RTWData
ProfiledNoSchedule
NeedsAutotuning
SingleThread
LatencyMismatch
Partitioned
MinExec
NoBlocks
ModelSettingsChanged
    end

    methods(Static)
        function state=getSubsystemState(subsystemHandle,hTopModel,modelSettingsChanged)
            model=bdroot(subsystemHandle);
            ui=get_param(model,'DataflowUI');

            if isempty(ui)
                state=dfs.analysis.MultithreadingState.NoDataForModel;
                return
            end

            topMostDataflowSubsystem=getTopMostDataflowSubsystem(ui,subsystemHandle);
            if topMostDataflowSubsystem==0
                state=dfs.analysis.MultithreadingState.Disabled;
                return
            end

            if topMostDataflowSubsystem~=subsystemHandle
                state=dfs.analysis.MultithreadingState.NewParent;
                return
            end

            mappingData=getBlkMappingData(ui,subsystemHandle);
            if isempty(mappingData)


                state=dfs.analysis.MultithreadingState.NoDataForSubsystem;
                return
            end


            if mappingData.Attributes==0
                state=dfs.analysis.MultithreadingState.NoDataForSubsystem;
                return
            end



            if modelSettingsChanged
                state=dfs.analysis.MultithreadingState.ModelSettingsChanged;
                return
            end


            if bitget(mappingData.Attributes,4)
                state=dfs.analysis.MultithreadingState.RTWData;
                return
            end





            if~bitget(mappingData.Attributes,11)

                if bitget(mappingData.Attributes,9)

                    costData=mappingData.getCostData;
                    if bitget(costData.Attributes,8)
                        state=dfs.analysis.MultithreadingState.ProfiledNoSchedule;
                    else

                        state=dfs.analysis.MultithreadingState.NeedsAutotuning;
                    end
                end
                return
            end





            if bitget(mappingData.Attributes,10)
                state=dfs.analysis.MultithreadingState.MinExec;
                return
            end






            if mappingData.NumberOfBlocks==0
                state=dfs.analysis.MultithreadingState.NoBlocks;
                return
            end





            if bitget(mappingData.Attributes,8)
                state=dfs.analysis.MultithreadingState.SingleThread;
                return
            end




            if ui.IsEditPhase||~any(strcmp(get_param(hTopModel,'SimulationStatus'),{'stopped','terminating'}))
                specifiedLatency=double(mappingData.SpecifiedLatency);
                currentLatency=getEvalLatency(ui,subsystemHandle);
                if currentLatency~=specifiedLatency
                    state=dfs.analysis.MultithreadingState.LatencyMismatch;
                    return
                end
            end

            assert(bitget(mappingData.Attributes,11)==1,'Not partitioned');
            state=dfs.analysis.MultithreadingState.Partitioned;
        end
    end
end


