classdef checkDecoupleSUDBoundary<handle




    methods
        function obj=checkDecoupleSUDBoundary()
        end
    end

    methods(Static)
        function reportObject=runFailSafe(analyzerScope)
            try
                reportObject=DataTypeWorkflow.Advisor.checkDecoupleSUDBoundary.run(analyzerScope);
            catch exDecoupleSUD
                reportObject{1}=analyzerScope.reportInternalErrorFromExceptionInScope(exDecoupleSUD);
            end
        end

        function reportObject=run(analyzerCheck)

            noChangeEntry=DataTypeWorkflow.Advisor.CheckResultEntry(analyzerCheck.SelectedSystem);



            sudObject=get_param(analyzerCheck.SelectedSystem,'Object');
            if isa(sudObject,'Simulink.BlockDiagram')...
                ||DataTypeWorkflow.Advisor.Utils.isLibraryLinked(sudObject)...
                ||DataTypeWorkflow.Advisor.Utils.isUnderReadOnlySystem(sudObject)
                reportObject{1}=noChangeEntry.setPassWithoutChange();
                return;
            end


            decouplePortsCheckEntry=DataTypeWorkflow.Advisor.checkDecoupleSUDBoundary.decouplePort(analyzerCheck);




            if isempty(decouplePortsCheckEntry)
                reportObject{1}=noChangeEntry.setPassWithoutChange();
            else
                reportObject=decouplePortsCheckEntry;
            end
        end

        function decoupledPorts=decouplePort(analyzerCheck)

            portHandlePairs=DataTypeWorkflow.Advisor.checkDecoupleSUDBoundary.getPortUpdateViaModelCompile(analyzerCheck);


            decoupledPorts=[];


            for idxIn=1:size(portHandlePairs.InputPairs,1)

                if~portHandlePairs.InputDrivenByDTC(idxIn)


                    blockName=get_param(portHandlePairs.InputPairs(idxIn,1),'parent');
                    checkEntry=DataTypeWorkflow.Advisor.CheckResultEntry(blockName);
                    beforeV=blockName;

                    if portHandlePairs.InputIsBus(idxIn)


                        decoupledPorts{end+1}=checkEntry.setFailWithoutChange(beforeV,...
                        DataTypeWorkflow.Advisor.internal.CauseRationale([],'busUsage'));%#ok<AGROW>
                    elseif DataTypeWorkflow.Advisor.checkDecoupleSUDBoundary.determineInputNotForConversion(portHandlePairs,idxIn)



                        decoupledPorts{end+1}=checkEntry.setPassWithoutChange();%#ok<AGROW>
                    else


                        DataTypeWorkflow.Advisor.Utils.DTCInsertionAheadInPort(portHandlePairs.InputPairs(idxIn,1),portHandlePairs.InputPairs(idxIn,2));

                        decoupledPorts{end+1}=checkEntry.setPassWithChange(beforeV,'DTC');%#ok<AGROW>

                    end
                end
            end



            portHandlePairs=DataTypeWorkflow.Advisor.checkDecoupleSUDBoundary.getPortUpdateViaModelCompile(analyzerCheck);

            for idxOut=1:size(portHandlePairs.OutputPairs,1)

                if~portHandlePairs.OutputDrivesDTC(idxOut)

                    blockName=get_param(portHandlePairs.OutputPairs(idxOut,2),'parent');
                    checkEntry=DataTypeWorkflow.Advisor.CheckResultEntry(blockName);
                    beforeV=blockName;

                    if portHandlePairs.OutputIsBus(idxOut)


                        decoupledPorts{end+1}=checkEntry.setFailWithoutChange(beforeV,...
                        DataTypeWorkflow.Advisor.internal.CauseRationale([],'busUsage'));%#ok<AGROW>
                    elseif DataTypeWorkflow.Advisor.checkDecoupleSUDBoundary.determineOutputNotForConversion(portHandlePairs,idxOut)



                        decoupledPorts{end+1}=checkEntry.setPassWithoutChange();%#ok<AGROW>
                    else

                        DataTypeWorkflow.Advisor.Utils.DTCInsertionAfterOutPort(portHandlePairs.OutputPairs(idxOut,1),portHandlePairs.OutputPairs(idxOut,2));
                        decoupledPorts{end+1}=checkEntry.setPassWithChange(beforeV,'DTC');%#ok<AGROW>

                    end
                end
            end
        end
        function portHandlePairs=getPortUpdateViaModelCompile(analyzerCheck)

            compileModelHandler=fixed.internal.modelcompilehandler.ModelCompileHandler(analyzerCheck.TopModel);
            try
                compileModelHandler.start();
            catch FailToCompile
                rethrow(FailToCompile);
            end

            portHandlePairs=fxptopo.internal.getInterfacePortHandlePairs(analyzerCheck.SelectedSystem);


            compileModelHandler.stop();

        end

        function isInputNotForConversion=determineInputNotForConversion(portHandlePairs,index)

            isInputNotForConversion=(portHandlePairs.InputIsFcnCall(index)||portHandlePairs.InputIsBoolean(index)||portHandlePairs.InputIsString(index));
        end
        function isOutputNotForConversion=determineOutputNotForConversion(portHandlePairs,index)

            isOutputNotForConversion=(portHandlePairs.OutputIsFcnCall(index)||portHandlePairs.OutputIsBoolean(index)||portHandlePairs.OutputIsString(index));
        end

    end
end


