classdef DependencyGraph<slreportgen.report.Reporter






































    properties


Source






        Layout="Vertical"







SnapShot
    end

    methods(Static,Access=private)
        function diagram=createSnapshot(this,layout)
            sourcePath=split(this,filesep);
            fileWithExtension=sourcePath(end);
            fileName=split(fileWithExtension,".");
            filepathForComponentDiagramSnapshot=strcat(userpath,filesep,fileName(1),'_dg.png');

            if layout=="Vertical"
                dependencies.internal.viewer.export.toImage(this,...
                filepathForComponentDiagramSnapshot,...
                Layout=dependencies.internal.viewer.Layout.VERTICAL);
            elseif layout=="Horizontal"
                dependencies.internal.viewer.export.toImage(this,...
                filepathForComponentDiagramSnapshot,...
                Layout=dependencies.internal.viewer.Layout.HORIZONTAL);
            end
            imgObj=mlreportgen.report.FormalImage(filepathForComponentDiagramSnapshot{1});
            imgObj.Caption="Dependency Graph";
            diagram=imgObj;
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.Component})
        function snapshot=getSnapShot(f,~)

            snapshot=copy(f.SnapShot);
            snapshot=systemcomposer.rptgen.report.DependencyGraph.createSnapshot(f.Source,f.Layout);
        end
    end

    methods
        function this=DependencyGraph(varargin)
            this=this@slreportgen.report.Reporter(varargin{:});
            this.SnapShot=slreportgen.report.Diagram();
            this.TemplateName="DependencyGraph";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.DependencyGraph.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end
    end

    methods(Access=protected,Hidden)
        result=openImpl(rpt,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)
            path=systemcomposer.rptgen.report.DependencyGraph.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.DependencyGraph");
        end
    end
end