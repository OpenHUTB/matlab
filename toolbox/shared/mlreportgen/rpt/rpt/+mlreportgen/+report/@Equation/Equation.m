classdef Equation<mlreportgen.report.Reporter&...
    mlreportgen.report.mixin.SnapshotMaker













































































    properties


















        Content{mustBeEquation(Content,"Content")}=[]




















        FontSize{mustBeInteger(FontSize),...
        mustBeSingleValue}=[]






















        Color{mustBeColor(Color)}=[]
























        BackgroundColor{mustBeColor(BackgroundColor)}=[]




































        DisplayInline{mustBeLogical(DisplayInline)}=false;

























        SnapshotFormat{mustBeMember(SnapshotFormat,["png","emf","svg"])}="svg";














        UseDirectRenderer{mlreportgen.report.validators.mustBeLogical}=false;
    end

    methods
        function equation=Equation(varargin)
            if length(varargin)==1
                varargin={'Content',varargin{1}};
            end
            equation=equation@mlreportgen.report.Reporter(varargin{:});

            if isempty(equation.TemplateName)
                equation.TemplateName='Equation';
            end
        end

        function imgpath=getSnapshotImage(equation,rpt)







            if isempty(char(equation.Content))
                error(message("mlreportgen:report:error:emptyEquationContent"));
            end

            fontSize=equation.FontSize;
            if isempty(fontSize)
                fontSize=14;
            end

            if~equation.UseDirectRenderer

                color=equation.Color;
                backgroundColor=equation.BackgroundColor;
                ext=equation.SnapshotFormat;


                switch ext
                case 'emf'
                    if isdocx(rpt)
                        if ispc
                            format='-dmeta';
                        else
                            error(message("mlreportgen:report:error:invalidPlatformForEMF"));
                        end
                    else
                        error(message("mlreportgen:report:error:invalidReportTypeForEMF"));
                    end
                case 'png'
                    format='-dpng';
                otherwise



                    format='-dsvg';
                end


                imgpath=rpt.generateFileName(ext);
                mlreportgen.utils.internal.createEquationImage(...
                char(imgpath),char(equation.Content),format,fontSize,color,backgroundColor);
            else

                if~strcmp(equation.SnapshotFormat,'png')

                    warning(message(...
                    "mlreportgen:report:warning:invalidJSRendererSnapshotFormat",...
                    equation.SnapshotFormat));
                end

                jsRenderer=mlreportgen.widgets.EquationRenderer;
                jsRenderer.TexContent=equation.Content;
                jsRenderer.SnapshotFormat="png";
                jsRenderer.Style.FontSize=strcat(num2str(fontSize),'pt');

                if~isempty(equation.Color)
                    jsRenderer.Style.Color=equation.Color;
                end




                if~isempty(equation.BackgroundColor)
                    warning(message("mlreportgen:report:warning:backgroundColorNotSupported"));




                end

                imgpath=jsRenderer.createEquationImage();
            end
        end

        function content=getContentReporter(equation,rpt)






            content=[];
            if isa(equation.Content,'mlreportgen.report.ReporterBase')
                content=equation.Content;
            end
            if isempty(content)
                content=mlreportgen.report.InlineContent("Content");
                img=getSnapshotImage(equation,rpt);
                content.Content=mlreportgen.dom.Image(img);
                content.Content.Style=[content.Content.Style...
                ,{mlreportgen.dom.ScaleToFit}];
                content.TemplateName='EquationContent';
                content.TemplateSrc=equation;
            end
        end

        function impl=getImpl(this,rpt)



            impl=[];

            if isempty(char(this.Content))

                error(message("mlreportgen:report:error:emptyEquationContent"));
            else

                if(this.DisplayInline)




                    img=getSnapshotImage(this,rpt);
                    impl=mlreportgen.dom.Image(img);
                else


                    impl=getImpl@mlreportgen.report.Reporter(this,rpt);
                end
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.Equation})
        function content=getContent(equation,rpt)
            if ischar(equation.Content)||isstring(equation.Content)
                content=getContentReporter(equation,rpt);
            else
                content=equation.Content;
            end
        end
    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()


            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)






            path=mlreportgen.report.Equation.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.Equation");
        end

    end


end


function mustBeEquation(varargin)
    mlreportgen.report.validators.mustBeEquation(varargin{:});
end

function mustBeColor(varargin)

    mlreportgen.report.validators.mustBeString(varargin{:});
end

function mustBeSingleValue(varargin)
    mlreportgen.report.validators.mustBeSingleValue(varargin{:});
end

function mustBeLogical(varargin)
    mlreportgen.report.validators.mustBeLogical(varargin{:});
end

