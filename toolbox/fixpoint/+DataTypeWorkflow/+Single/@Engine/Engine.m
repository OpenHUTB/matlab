classdef Engine<DataTypeWorkflow.DesignEnvironment












    properties(Constant,Hidden,Access=private)
        Instance=DataTypeWorkflow.Single.Engine;
    end


    properties(Hidden,Access=private)
        scope=[];
        analyzer=[]
        converter=[]
        mlfbConverter=[]
    end

    properties(Access=protected)
        MdlRefAccelOnly={};
    end


    events
CompatibilityCompletedEvent
ConvertCompletedEvent
VerifyCompletedEvent
    end


    methods(Static)
        function eng=getInstance()
            eng=DataTypeWorkflow.Single.Engine.Instance;
        end
    end


    methods(Access=private)

        function eng=Engine()
            eng@DataTypeWorkflow.DesignEnvironment();

            mlock;
        end
    end



    methods



        function report=run(eng,selectedSystem,varargin)

            if nargin==3
                topModel=varargin{1};
            else

                topModel=[];
            end

            report=DataTypeWorkflow.Single.Report(selectedSystem);



            report.SetupInfo=eng.setup(selectedSystem,topModel);
            if~isempty(report.SetupInfo.err)
                notify(eng,'CompatibilityCompletedEvent',fxptui.UIEventData(report.SetupInfo));
                return
            end



            report.RestorePointInfo=DataTypeWorkflow.Advisor.checkRestorePoint.runFailSafe(eng.TopModel);




            report.CheckInfo=eng.check();

            notify(eng,'CompatibilityCompletedEvent',fxptui.UIEventData(report.CheckInfo));
            if~report.CheckInfo.ready

                return
            end



            report.SUDBoundary=DataTypeWorkflow.Advisor.checkDecoupleSUDBoundary.runFailSafe(eng.scope);




            report.ConvertInfo=eng.convert();

            notify(eng,'ConvertCompletedEvent',fxptui.UIEventData(report.ConvertInfo));
            if~isempty(report.ConvertInfo.err)
                return
            end


            report.VerifyInfo=eng.verify();

            notify(eng,'VerifyCompletedEvent',fxptui.UIEventData(report.VerifyInfo));


        end


        function reportInfo=setup(eng,selectedSystem,topModel)
            reportInfo.err={};
            try

                if isempty(topModel)
                    topModel=bdroot(selectedSystem);
                end

                setup@DataTypeWorkflow.DesignEnvironment(eng,selectedSystem,'TopModel',topModel);
                eng.MdlRefAccelOnly=DataTypeWorkflow.Utils.getMdlRefAccelOnly(eng.MdlRefGraph);
                eng.mlfbConverter=coder.internal.mlfbDoubleToSingle.ConvertSystemToSingle;
                eng.mlfbConverter.initialize(eng.TopModel);

                aScope=DataTypeWorkflow.Advisor.analyzerScope(selectedSystem,eng.TopModel,eng.AllSystems,eng.MdlRefAccelOnly);
                eng.scope=aScope;
                eng.analyzer=DataTypeWorkflow.Single.Analyzer(aScope,eng.mlfbConverter);
                eng.converter=DataTypeWorkflow.Single.Converter(aScope,eng.mlfbConverter);
            catch ME
                reportInfo.err=ME;
            end
        end



        function reportInfo=check(eng)
            reportInfo=eng.analyzer.check();
        end





        function reportInfo=convert(eng)
            DataTypeWorkflow.Utils.updateDirtyModels(eng.analyzer.DirtyModels,'off');
            reportInfo=eng.converter.convert();
            DataTypeWorkflow.Utils.updateDirtyModels(eng.analyzer.DirtyModels,'on');
        end



        function reportInfo=verify(eng)
            reportInfo=eng.analyzer.verify();
        end
    end
end


