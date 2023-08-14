


classdef MappedInput<stm.internal.InputReader.Base

    properties
        SldvScenario struct;
    end

    methods
        function this=MappedInput(simIn,runTestCfg,simWatcher)
            this=this@stm.internal.InputReader.Base(simIn,runTestCfg,simWatcher);
        end

        function setup(this)
            varsLoaded=[];
            vars=[];
            isExcel=false;
            switch this.SimIn.InputType
            case stm.internal.InputTypes.Mat
                [varsLoaded,vars]=stm.internal.MRT.share.loadMatFile(this.SimIn.InputFilePath);
            case stm.internal.InputTypes.Spreadsheet
                [varsLoaded,vars]=stm.internal.InputReader.MappedInput.loadSpreadsheet(this.SimIn);
                isExcel=true;
            case stm.internal.InputTypes.Sldv
                [this.SimIn.InputMappingString,this.SldvScenario,sldvVarName]=...
                stm.internal.MRT.share.loadSldvFile(this.SimIn.InputFilePath,str2double(this.SimIn.ExcelSheet));
                varsLoaded=string(sldvVarName);
            end

            this.SimWatcher.cleanupIteration.VarsLoaded=varsLoaded;
            this.SimWatcher.cleanupIteration.Vars=vars;
            this.SimWatcher.cleanupIteration.IsExcel=isExcel;
        end

        function override(this)

            this.RunTestCfg.SimulationInput=...
            this.RunTestCfg.SimulationInput.setExternalInput(this.SimIn.InputMappingString);

            if~isempty(this.SldvScenario)

                dStopTime=this.SldvScenario.timeValues(end);
                stopTime=stm.internal.util.SimulinkModel.formatSimTime(dStopTime);
                this.RunTestCfg.SimulationInput=...
                this.RunTestCfg.SimulationInput.setModelParameter('StopTime',stopTime);
            end
        end

        function getExternalInputRunData(this)
            runData=stm.internal.MRT.share.createExternalInputRunFromFile(...
            this.SimIn,this.RunTestCfg.runningOnPCT,this.SimIn.inputDataSetsRunFile);

            prevData=this.RunTestCfg.out.ExternalInputRunData;
            this.RunTestCfg.out.ExternalInputRunData=[prevData,runData];
        end
    end

    methods(Static)
        function[varsLoaded,vars]=loadSpreadsheet(simIn)
            vars=[];
            if simIn.UseXls
                simIndex=stm.internal.getTcpProperty(simIn.PermutationId,'SimIndex');
                [varsLoaded,vars]=stm.internal.util.loadExcelFileWithOptions(simIn.InputFilePath,...
                simIn.ExcelSheet,simIn.Ranges,simIn.Model,...
                xls.internal.SourceTypes.Input,true,simIndex);
            elseif ispc
                varsLoaded=stm.internal.util.loadExcelFile(simIn.InputFilePath);
            else
                stm.internal.MRT.share.error('stm:general:OldExcelFormatNotSupportedAsInputs');
            end
        end
    end
end
