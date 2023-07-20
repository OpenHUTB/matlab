classdef Engine<DataTypeWorkflow.DesignEnvironment





    properties(Constant,Hidden,Access=private)
        Instance=DataTypeWorkflow.Advisor.Engine;

        AnalyzerInternalRunName='D2S_Run_Collector_Internal_Run_Name';
    end


    properties(Access=protected)
        MdlRefAccelOnly={};
    end


    methods(Static)
        function eng=getInstance()
            eng=DataTypeWorkflow.Advisor.Engine.Instance;
        end
    end


    methods(Access=private)

        function eng=Engine()
            eng@DataTypeWorkflow.DesignEnvironment();
        end

        function initializeDataset(this,modelName)

            appdata=SimulinkFixedPoint.getApplicationData(modelName);

            appdata.ScaleUsing=this.AnalyzerInternalRunName;
            runObj=appdata.dataset.getRun(appdata.ScaleUsing);
            runObj.initialize(modelName);
        end
    end


    methods


        function report=runSimBasedChecks(eng,selectedSystem,topModel)

            report=DataTypeWorkflow.Advisor.Report(selectedSystem);


            report.SetupInfo=eng.setup(selectedSystem,topModel);


            aScope=DataTypeWorkflow.Advisor.analyzerScope(selectedSystem,topModel,eng.AllSystems,eng.MdlRefAccelOnly);


            report.RestorePoint=DataTypeWorkflow.Advisor.checkRestorePoint.runFailSafe(eng.TopModel);


            report.HardwareSetting=DataTypeWorkflow.Advisor.checkTargetHardware().runFailSafe(aScope);
            report.DiagnosticSetting=DataTypeWorkflow.Advisor.checkDiagnostics.runFailSafe(aScope);

            report.UnsupportedConstruct=DataTypeWorkflow.Advisor.checkUnsupportedConstruct.runFailSafe(aScope);

            report.SUDBoundary=DataTypeWorkflow.Advisor.checkDecoupleSUDBoundary.runFailSafe(aScope);
        end


        function report=runDerivedBasedChecks(eng,selectedSystem,topModel)

            report=DataTypeWorkflow.Advisor.Report(selectedSystem);


            report.SetupInfo=eng.setup(selectedSystem,topModel);


            aScope=DataTypeWorkflow.Advisor.analyzerScope(selectedSystem,topModel,eng.AllSystems,eng.MdlRefAccelOnly);



            report.RestorePoint=DataTypeWorkflow.Advisor.checkRestorePoint.runFailSafe(eng.TopModel);


            report.HardwareSetting=DataTypeWorkflow.Advisor.checkTargetHardware().runFailSafe(aScope);
            report.DiagnosticSetting=DataTypeWorkflow.Advisor.checkDiagnostics.runFailSafe(aScope);

            report.UnsupportedConstruct=DataTypeWorkflow.Advisor.checkUnsupportedConstruct.runFailSafe(aScope);


            report.DesignRange=DataTypeWorkflow.Advisor.checkSUDInterfaceDesignRange.runFailSafe(aScope);

            report.SUDBoundary=DataTypeWorkflow.Advisor.checkDecoupleSUDBoundary.runFailSafe(aScope);
        end


        function reportInfo=setup(eng,selectedSystem,topModel)
            checkTopEntry=DataTypeWorkflow.Advisor.CheckResultEntry(selectedSystem);
            try

                setup@DataTypeWorkflow.DesignEnvironment(eng,selectedSystem,'TopModel',topModel);

                eng.initializeDataset(topModel);
                eng.MdlRefAccelOnly=DataTypeWorkflow.Utils.getMdlRefAccelOnly(eng.MdlRefGraph);
                reportInfo=checkTopEntry.setPassWithoutChange();
            catch ME


                reportInfo=checkTopEntry.setFailWithoutChange(selectedSystem,...
                DataTypeWorkflow.Advisor.internal.CauseRationale(ME,'modelNotAccessible'));
            end
        end



        function facade=getWorkflowTopologyFacade(this)
            appdata=SimulinkFixedPoint.getApplicationData(this.TopModel);
            facade=appdata.dataset.WorkflowTopologyFacade;
        end
    end
end
