classdef ReportSectionView<evolutions.internal.ui.tools.ToolstripSection





    properties(Constant)

        Title='Report';
        Name='Report';
    end

    properties(SetAccess=protected)

GenerateReportButton
GenerateReportIcon

    end

    methods
        function this=ReportSectionView(parent)
            this@evolutions.internal.ui.tools.ToolstripSection(parent);
        end

        function enableWidget(this,enabled,widgetName)

            assert(strcmp(widgetName,'generateReport'));
            this.GenerateReportButton.Enabled=enabled;
        end
    end

    methods(Access=protected)
        function createSectionComponents(this)
            createGenerateReportButtonGroup(this);
        end

        function layoutSection(this)
            add(this.Section.addColumn(),this.GenerateReportButton);
        end

        function createGenerateReportButtonGroup(this)

            this.GenerateReportIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(this.IconsFilePath,'report_generation_16.png'));




            this.GenerateReportButton=this.createButton(...
            getString(message('evolutions:ui:GenerateReportButton')),...
            this.GenerateReportIcon,createChildTag(this,'Create Report'),...
            getString(message('evolutions:ui:GenerateReportToolTip')));
        end

    end
end


