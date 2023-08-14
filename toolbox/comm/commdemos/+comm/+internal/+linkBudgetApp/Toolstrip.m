classdef Toolstrip<matlab.ui.internal.toolstrip.TabGroup




    properties
Application
    end

    properties(SetAccess=protected,Hidden)
        AnalyzeSection;
    end

    methods
        function this=Toolstrip(hApp,varargin)

            this@matlab.ui.internal.toolstrip.TabGroup();
            this.Tag='LinkBudgetAnalyzer';
            this.Application=hApp;

            mainTab=this.addTab(getString(message('comm_demos:LinkBudgetApp:MainTabName')));
            mainTab.Tag='home';

            this.AnalyzeSection=createAnalyzeSection(this);
            mainTab.add(this.AnalyzeSection);
        end

    end

    methods(Access=protected)

        function h=createAnalyzeSection(this)

            import matlab.ui.internal.toolstrip.*;

            hApp=this.Application;
            h=Section;

            h.Title=getString(message('comm_demos:LinkBudgetApp:Analyze'));
            h.Tag='analyzeSection';
            analyzeButton=Button(getString(message('comm_demos:LinkBudgetApp:Analyze')),Icon.RUN_24);
            analyzeButton.Tag='analyzeButton';
            analyzeButton.Description=getString(message('comm_demos:LinkBudgetApp:AnalyzeButtonDescription'));
            analyzeButton.ButtonPushedFcn=hApp.initCallback(@this.analyzeLinkBudget);
            col=h.addColumn();
            col.add(analyzeButton);

        end
    end

    methods(Hidden)
        function exportMatlabCodeCallback(this,~,~)
            exportMatlabCode(this);
        end
        function analyzeLinkBudget(this,~,~)



            figure(this.Application.Results.Figure);
            drawnow;


            clearAllMessages(this.Application.Uplink);
            clearAllMessages(this.Application.Downlink);

            analyzeLinkBudget(this.Application.DataModel);
        end

    end
end


