classdef TitlePage<mlreportgen.report.Reporter

























































































































































    properties





















        Title{mustBeBlock(Title,"Title")}=[]















        Subtitle{mustBeBlock(Subtitle,"Subtitle")}=[]




















        Image{mustBeImageOrSnapshotMaker(Image,"Image")}=[]



















        Author{mustBeBlock(Author,"Author")}=getenv('username')















        Publisher{mustBeBlock(Publisher,"Publisher")}=[]















        PubDate{mustBeBlock(PubDate,"PubDate")}=date
    end

    properties(SetAccess={?mlreportgen.report.TitlePage,?mlreportgen.report.ReporterBase})












        Layout{mustBeInstanceOf(...
        'mlreportgen.report.ReporterLayout',Layout)}=[]
    end

    methods

        function tp=TitlePage(varargin)
            tp=tp@mlreportgen.report.Reporter(varargin{:});

            if isempty(tp.TemplateName)
                tp.TemplateName='TitlePage';
            end
            if isempty(tp.Layout)
                tp.Layout=mlreportgen.report.ReporterLayout(tp);
            end
        end

    end

    methods
        function reporter=getTitleReporter(tp)









            reporter=getInlineReporter(tp,"Title",tp.Title);
        end

        function reporter=getSubtitleReporter(tp)









            reporter=getInlineReporter(tp,"Subtitle",tp.Subtitle);
        end

        function reporter=getImageReporter(tp,rpt)









            if ischar(tp.Image)||isstring(tp.Image)

                image=mlreportgen.dom.Image(tp.Image);
                image.Style=[image.Style,{mlreportgen.dom.ScaleToFit}];
                reporter=getInlineReporter(tp,"Image",image);
            elseif isa(tp.Image,'mlreportgen.report.mixin.SnapshotMaker')
                imagePath=getSnapshotImage(tp.Image,rpt);
                image=mlreportgen.dom.Image(imagePath);
                image.Style=[image.Style,{mlreportgen.dom.ScaleToFit}];
                reporter=getInlineReporter(tp,"Image",image);
            elseif isa(tp.Image,'mlreportgen.report.Reporter')

                reporter=tp.Image;
            else

                reporter=getInlineReporter(tp,"Image",tp.Image);
            end
        end

        function reporter=getAuthorReporter(tp)









            reporter=getInlineReporter(tp,"Author",tp.Author);
        end

        function reporter=getPublisherReporter(tp)









            reporter=getInlineReporter(tp,"Publisher",tp.Publisher);
        end

        function reporter=getPubDateReporter(tp)









            reporter=getInlineReporter(tp,"PubDate",tp.PubDate);
        end

    end

    methods(Access=protected,Hidden)


        result=openImpl(reporter,impl,varargin)

        function content=getInlineReporter(tp,holeId,inline)
            content=mlreportgen.report.InlineContent(holeId);
            content.TemplateName="TitlePage"+holeId;
            content.TemplateSrc=tp;
            content.Content=inline;
        end

        function processHole(reporter,form,rpt)

            if strcmp(form.CurrentHoleId(1),'#')
                if~isempty(reporter.Layout)&&~isa(form,'mlreportgen.dom.PageHdrFtr')
                    updateLayout(reporter.Layout,rpt);
                end
            else
                fillHole(reporter,form,rpt);
            end
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.TitlePage})

        function content=getTitle(tp,report)%#ok<INUSD>
            if mlreportgen.report.ReporterBase.isInlineContent(tp.Title)
                content=getTitleReporter(tp);
            else
                content=tp.Title;
            end
        end

        function content=getSubtitle(tp,report)%#ok<INUSD>
            if mlreportgen.report.ReporterBase.isInlineContent(tp.Subtitle)
                content=getSubtitleReporter(tp);
            else
                content=tp.Subtitle;
            end
        end

        function content=getImage(tp,rpt)

            if ischar(tp.Image)||isstring(tp.Image)||...
                mlreportgen.report.ReporterBase.isInlineContent(tp.Image)||...
                isa(tp.Image,'mlreportgen.report.mixin.SnapshotMaker')
                content=getImageReporter(tp,rpt);
            else

                content=tp.Image;
            end
        end

        function content=getAuthor(tp,report)%#ok<INUSD>
            if mlreportgen.report.ReporterBase.isInlineContent(tp.Author)
                content=getAuthorReporter(tp);
            else
                content=tp.Author;
            end
        end

        function content=getPublisher(tp,report)%#ok<INUSD>
            if mlreportgen.report.ReporterBase.isInlineContent(tp.Publisher)
                content=getPublisherReporter(tp);
            else
                content=tp.Publisher;
            end
        end

        function content=getPubDate(tp,report)%#ok<INUSD>
            if mlreportgen.report.ReporterBase.isInlineContent(tp.PubDate)
                content=getPubDateReporter(tp);
            else
                content=tp.PubDate;
            end
        end

    end

    methods(Static)

        function path=getClassFolder()



            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)






            path=mlreportgen.report.TitlePage.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)













            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.TitlePage");
        end


    end
end


function mustBeBlock(varargin)
    mlreportgen.report.validators.mustBeBlock(varargin{:});
end
function mustBeImageOrSnapshotMaker(varargin)
    mlreportgen.report.validators.mustBeImageOrSnapshotMaker(varargin{:});
end
function mustBeInstanceOf(varargin)
    mlreportgen.report.validators.mustBeInstanceOf(varargin{:});
end

