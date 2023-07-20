classdef SimulinkProfilerReporter<mlreportgen.report.Reporter

    properties



        ReportTitle;
        GenDateInfo=[];
        SummaryString=[];









        TableData;
        TableTitle;
        SummaryData;
    end

    methods
        function obj=SimulinkProfilerReporter(varargin)
            obj=obj@mlreportgen.report.Reporter(varargin{:});


            obj.TemplateName="SimulinkProfilerReporter";


            if isempty(obj.GenDateInfo)
                obj.GenDateInfo=...
                DAStudio.message('Simulink:Profiler:ReportGeneratedTimeString',datestr(datetime));
            end
            if isempty(obj.SummaryString)
                obj.SummaryString=DAStudio.message('Simulink:Profiler:SummaryString');
            end

        end
    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.BaseTable})


        function content=getTable(this,~)
            headers={DAStudio.message('Simulink:Profiler:BlockPath'),...
            DAStudio.message('Simulink:Profiler:TotalTime'),...
            DAStudio.message('Simulink:Profiler:SelfTime'),...
            DAStudio.message('Simulink:Profiler:NumCalls')};
            data=this.TableData;


            content=mlreportgen.dom.FormalTable(headers,data);
        end


        function content=getSummaryDataTable(this,~)
            data=this.SummaryData;


            content=mlreportgen.dom.FormalTable(data);
        end

    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=Simulink.internal.SimulinkProfiler.SimulinkProfilerReporter.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end

    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function createTemplate(templatePath,type)
            path=SimulinkProfilerReporter.getClassFolder();
            mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function customizeReporter(toClasspath)
            mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"SimulinkProfilerReporter");
        end

    end
end