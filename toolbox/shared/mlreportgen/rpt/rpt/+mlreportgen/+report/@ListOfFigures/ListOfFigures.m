classdef ListOfFigures<mlreportgen.report.Reporter















































































    properties


















        Title{mustBeBlock(Title,"Title")}=[]
    end

    properties(Dependent)














        LeaderPattern;
    end

    properties(Access=private)

        LOFObj=[];
    end

    properties(SetAccess={?mlreportgen.report.ListOfFigures,?mlreportgen.report.ReporterBase})







        Layout{mustBeInstanceOf('mlreportgen.report.ReporterLayout',Layout)}=[];
    end

    methods
        function this=ListOfFigures(varargin)
            if nargin==1
                varargin=[{'Title'},varargin];
            end

            this=this@mlreportgen.report.Reporter(varargin{:});




            if isempty(this.TemplateName)
                this.TemplateName="ListOfFigures";
            end

            if isempty(this.Layout)
                this.Layout=mlreportgen.report.ReporterLayout(this);
                this.Layout.FirstPageNumber=[];
                this.Layout.PageNumberFormat='i';
            end

            if isempty(this.LOFObj)
                this.LOFObj=mlreportgen.dom.LOF;
            end


        end

        function set.LeaderPattern(this,value)

            mustBeNonempty(value);



            this.LOFObj.LeaderPattern=value;
        end

        function value=get.LeaderPattern(this)
            value=this.LOFObj.LeaderPattern;

        end

        function title=getTitleReporter(this)











            title=[];

            if isa(this.Title,'mlreportgen.report.ReporterBase')
                title=this.Title;
            end
            if isempty(title)
                title=mlreportgen.report.Title("Title");
                title.Content=this.Title;
                title.TemplateName='ListOfFiguresTitle';
                title.TemplateSrc=this;
                title.Translations.Owner='ListOfFigures';
                title.Translations.Content=this.getTranslations();
            end
        end

    end

    methods(Static)
        function path=getClassFolder()

            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)







            path=mlreportgen.report.ListOfFigures.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)













            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.ListOfFigures");
        end

    end

    methods(Static,Hidden)

        function translations=getTranslations()


            persistent INSTANCE;
            if isempty(INSTANCE)
                INSTANCE=mlreportgen.report.ReporterBase.parseTranslation(...
                mlreportgen.report.ListOfFigures.getClassFolder(),...
                "ListOfFiguresTitle.xml");
            end
            translations=INSTANCE;
        end

    end

    methods(Access=protected,Hidden)


        result=openImpl(reporter,impl,varargin)

        function processHole(this,form,rpt)

            if strcmp(form.CurrentHoleId(1),'#')
                if~isempty(this.Layout)&&~isa(form,'mlreportgen.dom.PageHdrFtr')
                    updateLayout(this.Layout,rpt);
                end
            else
                fillHole(this,form,rpt);
            end
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.ListOfFigures})
        function content=getTitle(this,report)%#ok<INUSD>
            if isempty(this.Title)||mlreportgen.report.ReporterBase.isInlineContent(this.Title)
                content=getTitleReporter(this);
            else
                content=this.Title;
            end
        end

        function content=getLOFObj(this,report)%#ok<INUSD>
            content=this.LOFObj;
        end


    end

end

function mustBeBlock(varargin)
    mlreportgen.report.validators.mustBeBlock(varargin{:});
end
function mustBeInstanceOf(varargin)
    mlreportgen.report.validators.mustBeInstanceOf(varargin{:});
end
