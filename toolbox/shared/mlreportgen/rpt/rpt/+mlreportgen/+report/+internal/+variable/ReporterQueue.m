classdef ReporterQueue<handle




















    properties

        FIFO={}
    end

    properties(Access=private)


        ReporterCount=0;
    end

    methods

        function add(this,reporter)

            this.FIFO{end+1}=reporter;



            reporter.registerLink();
        end

        function reporter=pop(this)


            reporter=[];
            if~isempty(this.FIFO)
                reporter=this.FIFO{1};
                this.FIFO(1)=[];
            end
        end

        function clear(this)


            this.FIFO={};
        end

        function init(this,reportOptions,varName,varValue)



            import mlreportgen.report.internal.variable.*


            this.clear();


            ReporterLinkResolver.instance().clear();


            reporter=...
            ReporterFactory.makeReporter(reportOptions,varName,varValue);


            this.add(reporter);
        end

        function content=run(this)





            content={};

            reporter=this.pop();
            count=1;
            while~isempty(reporter)&&...
                count<=reporter.ReportOptions.ObjectLimit
                reporterContent=reporter.report();
                if~isempty(reporterContent)
                    content{end+1}=reporterContent;%#ok<AGROW>
                end

                reporter=this.pop();
                count=count+1;
            end
        end

        function id=getReporterID(this)

            this.ReporterCount=this.ReporterCount+1;
            id=this.ReporterCount;
        end

    end

    methods(Static)
        function instance=instance()



            persistent INSTANCE
            if isempty(INSTANCE)
                INSTANCE=mlreportgen.report.internal.variable.ReporterQueue;
            end
            instance=INSTANCE;
        end
    end

end

