classdef checkSUDInterfaceDesignRange<handle




    methods
        function obj=checkSUDInterfaceDesignRange()
        end
    end

    methods(Static)
        function reportObject=runFailSafe(analyzerScope)
            try
                reportObject=DataTypeWorkflow.Advisor.checkSUDInterfaceDesignRange.run(analyzerScope);
            catch exDesignRange
                reportObject{1}=analyzerScope.reportInternalErrorFromExceptionInScope(exDesignRange);
            end
        end

        function reportObject=run(analyzerCheck)

            asExtension=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();

            missingRangeEntry={};


            if isa(get_param(analyzerCheck.SelectedSystem,'Object'),'Simulink.BlockDiagram')
                [InportHandle,OutportHandle]=DataTypeWorkflow.Advisor.internal.getRootModelPorts(analyzerCheck.SelectedSystem);
            else

                subSystemPath=Simulink.ID.getFullName(get_param(analyzerCheck.SelectedSystem,'Handle'));
                [InportHandle,OutportHandle]=fxptopo.internal.getInternalPortsForSubSystem(subSystemPath);
            end


            allPortsToCheck=[InportHandle',OutportHandle'];

            for idx=1:length(allPortsToCheck)

                blockObject=get_param(allPortsToCheck(idx),'Object');

                blkAutoscaler=asExtension.getAutoscaler(blockObject);

                [designMin,designMax]=blkAutoscaler.gatherDesignMinMax(blockObject,'1');

                if isempty(designMin)||isempty(designMax)


                    checkEntry=DataTypeWorkflow.Advisor.CheckResultEntry(blockObject.getFullName);
                    blockMissingRange=blockObject.BlockType;


                    if isa(blockObject,'Simulink.Inport')
                        missingRangeEntry{end+1}=checkEntry.setFailWithoutChange(blockMissingRange,...
                        DataTypeWorkflow.Advisor.internal.CauseRationale([],'DesignRangeFailWithoutChangeHeader'));%#ok<AGROW>
                    else

                        missingRangeEntry{end+1}=checkEntry.setWarnWithoutChange(blockMissingRange,...
                        DataTypeWorkflow.Advisor.internal.CauseRationale([],'DesignRangeWarnWithoutChangeHeader'));%#ok<AGROW>
                    end



                end

            end




            reportObject=missingRangeEntry;
        end
    end
end


