classdef analyzerScope<handle





    properties(Hidden,Access=public)

        SelectedSystem=''

        TopModel=''

        AllSystemsToScale={}


        SelectedSystemsToScale={}

        MdlRefAccelOnly={}
    end

    properties(SetAccess=private,GetAccess=public)
        DirtyModels={};
    end


    methods


        function analyzer=analyzerScope(selectedSystem,topModel,allSystemsToScale,mdlRefAccelOnly)
            analyzer.SelectedSystem=selectedSystem;
            analyzer.TopModel=topModel;
            analyzer.AllSystemsToScale=allSystemsToScale;
            analyzer.MdlRefAccelOnly=mdlRefAccelOnly;


            analyzer.SelectedSystemsToScale=[allSystemsToScale{1:end-1},{selectedSystem}];
            analyzer.DirtyModels={};
            analyzer.refreshDirtyModelsList();



            eng=DataTypeWorkflow.Advisor.Engine.getInstance;
            eng.setup(selectedSystem,topModel);
        end
    end


    methods(Hidden)
        function reportObject=reportInternalErrorFromExceptionInScope(this,exceptionSource)
            failSafeEntry=DataTypeWorkflow.Advisor.CheckResultEntry(this.SelectedSystem);
            reportObject=failSafeEntry.setFailWithoutChange(this.SelectedSystem,...
            DataTypeWorkflow.Advisor.internal.CauseRationale(exceptionSource,'internalErrors'));
        end

    end

    methods(Access=private)


        function refreshDirtyModelsList(analyzer)
            analyzer.DirtyModels={};
            for i=1:numel(analyzer.AllSystemsToScale)
                if strcmpi(get_param(analyzer.AllSystemsToScale{i},'Dirty'),'on')
                    analyzer.DirtyModels{end+1}=analyzer.AllSystemsToScale{i};
                end
            end
        end


    end
end
