classdef SequenceDiagram<slreportgen.report.Reporter

    properties
Name
ModelName
Snapshot
    end


    methods(Static,Access=private)
        function diagram=createSnapshot(this)
            exporter=sequencediagram.internal.print.Exporter(this.ModelName,this.Name);
            filepathForSequenceDiagramSnapshot=strcat(userpath,this.Name,'_sd.png');
            exporter.export(filepathForSequenceDiagramSnapshot,ImageFormat=sequencediagram.internal.print.ImageFormat.PNG);


            imgObj=mlreportgen.report.FormalImage(filepathForSequenceDiagramSnapshot);
            imgObj.Caption="Sequence Diagram";
            diagram=imgObj;
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.Component})
        function snapshot=getSnapshot(f,~)

            snapshot=copy(f.Snapshot);
            snapshot=systemcomposer.rptgen.report.SequenceDiagram.createSnapshot(f);
        end
    end

    methods
        function this=SequenceDiagram(varargin)
            this=this@slreportgen.report.Reporter(varargin{:});
            this.Snapshot=slreportgen.report.Diagram();
            this.TemplateName="SequenceDiagram";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.SequenceDiagram.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end

    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)
            path=systemcomposer.rptgen.report.SequenceDiagram.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.SequenceDiagram");
        end

    end
end