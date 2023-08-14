classdef TableOfContents<mlreportgen.report.Reporter








































































































    properties


















        Title{mustBeBlock(Title,"Title")}=[]
    end

    properties(Hidden)















        TOCObj{mustBeInstanceOf('mlreportgen.dom.TOC',TOCObj)}=[];
    end

    properties(Dependent)













NumberOfLevels


















LeaderPattern
    end

    properties(SetAccess={?mlreportgen.report.TableOfContents,?mlreportgen.report.ReporterBase})







        Layout{mustBeInstanceOf('mlreportgen.report.ReporterLayout',Layout)}=[];
    end

    methods
        function this=TableOfContents(varargin)
            if nargin==1
                varargin=[{'Title'},varargin];
            end
            this=this@mlreportgen.report.Reporter(varargin{:});

            if isempty(this.TemplateName)
                this.TemplateName='TableOfContents';
            end

            if isempty(this.Layout)
                this.Layout=mlreportgen.report.ReporterLayout(this);
                this.Layout.FirstPageNumber=1;
                this.Layout.PageNumberFormat='i';
            end


            if isempty(this.TOCObj)
                this.TOCObj=mlreportgen.dom.TOC;
            end
        end

        function set.TOCObj(this,value)

            mustBeNonempty(value);



            this.TOCObj=value;
        end

        function numberOfLevels=get.NumberOfLevels(this)


            numberOfLevels=this.TOCObj.NumberOfLevels;
        end

        function set.NumberOfLevels(this,value)



            mustBeNonempty(value);
            this.TOCObj.NumberOfLevels=value;
        end

        function leaderPattern=get.LeaderPattern(this)


            leaderPattern=this.TOCObj.LeaderPattern;
        end

        function set.LeaderPattern(this,value)





            mustBeNonempty(value);
            this.TOCObj.LeaderPattern=value;
        end

        function title=getTitleReporter(this)











            title=[];

            if isa(this.Title,'mlreportgen.report.ReporterBase')
                title=this.Title;
            end
            if isempty(title)
                title=mlreportgen.report.Title("Title");
                title.Content=this.Title;
                title.TemplateName='TableOfContentsTitle';
                title.TemplateSrc=this;
                title.Translations.Owner='TableOfContents';
                title.Translations.Content=this.getTranslations();
            end
        end

    end

    methods(Static)
        function path=getClassFolder()

            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)







            path=mlreportgen.report.TableOfContents.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)














            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.TableOfContents");
        end

    end

    methods(Static,Hidden)

        function translations=getTranslations()


            persistent INSTANCE;
            if isempty(INSTANCE)
                INSTANCE=mlreportgen.report.ReporterBase.parseTranslation(...
                mlreportgen.report.TableOfContents.getClassFolder(),...
                "TableOfContentsTitle.xml");
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

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.TableOfContents})
        function content=getTitle(this,report)%#ok<INUSD>
            if isempty(this.Title)||mlreportgen.report.ReporterBase.isInlineContent(this.Title)
                content=getTitleReporter(this);
            else
                content=this.Title;
            end
        end

        function content=getTOCObj(this,report)%#ok<INUSD>
            content=this.TOCObj;
        end

    end

end

function mustBeBlock(varargin)
    mlreportgen.report.validators.mustBeBlock(varargin{:});
end
function mustBeInstanceOf(varargin)
    mlreportgen.report.validators.mustBeInstanceOf(varargin{:});
end
