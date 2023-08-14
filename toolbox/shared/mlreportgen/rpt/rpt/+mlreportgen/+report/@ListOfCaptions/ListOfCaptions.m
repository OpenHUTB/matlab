classdef ListOfCaptions<mlreportgen.report.Reporter























































































    properties


















        Title{mustBeBlock(Title,"Title")}=[]
    end

    properties(Dependent)








        AutoNumberStreamName;














        LeaderPattern;
    end

    properties(Access=private)

        LOCObj=[];
    end

    properties(SetAccess={?mlreportgen.report.ListOfCaptions,?mlreportgen.report.ReporterBase})







        Layout{mustBeInstanceOf('mlreportgen.report.ReporterLayout',Layout)}=[];
    end

    methods
        function this=ListOfCaptions(varargin)
            if nargin==1
                varargin=[{'Title'},varargin];
            end

            this=this@mlreportgen.report.Reporter(varargin{:});
            createLOCObj(this);


            if isempty(this.TemplateName)
                this.TemplateName="ListOfCaptions";
            end

            if isempty(this.Layout)
                this.Layout=mlreportgen.report.ReporterLayout(this);
                this.Layout.FirstPageNumber=[];
                this.Layout.PageNumberFormat='i';
            end

        end

        function set.AutoNumberStreamName(this,value)

            mustBeNonempty(value);



            createLOCObj(this);
            this.LOCObj.AutoNumberStreamName=value;
        end

        function value=get.AutoNumberStreamName(this)
            value=this.LOCObj.AutoNumberStreamName;
        end

        function set.LeaderPattern(this,value)

            mustBeNonempty(value);



            createLOCObj(this);
            this.LOCObj.LeaderPattern=value;
        end

        function value=get.LeaderPattern(this)
            value=this.LOCObj.LeaderPattern;

        end

        function title=getTitleReporter(this)













            title=[];

            if isa(this.Title,'mlreportgen.report.ReporterBase')
                title=this.Title;
            end
            if isempty(title)
                title=mlreportgen.report.Title("Title");
                if isempty(this.Title)
                    title.Content=getString(message("mlreportgen:report:ListOfCaptions:listOf",...
                    this.LOCObj.AutoNumberStreamName));
                else
                    title.Content=this.Title;
                end
                title.TemplateName="ListOfCaptionsTitle";
                title.TemplateSrc=this;
            end
        end

    end

    methods(Static)
        function path=getClassFolder()

            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)







            path=mlreportgen.report.ListOfCaptions.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)













            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.ListOfCaptions");
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

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.ListOfCaptions})
        function content=getTitle(this,report)%#ok<INUSD>
            if isempty(this.Title)||mlreportgen.report.ReporterBase.isInlineContent(this.Title)
                content=getTitleReporter(this);
            else
                content=this.Title;
            end
        end

        function content=getLOCObj(this,report)%#ok<INUSD>
            content=this.LOCObj;
        end

    end

    methods(Access=private)
        function createLOCObj(this)

            if isempty(this.LOCObj)
                this.LOCObj=mlreportgen.dom.LOC;
            end
        end
    end

end

function mustBeBlock(varargin)
    mlreportgen.report.validators.mustBeBlock(varargin{:});
end
function mustBeInstanceOf(varargin)
    mlreportgen.report.validators.mustBeInstanceOf(varargin{:});
end
