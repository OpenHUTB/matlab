classdef Chapter<mlreportgen.report.Section






























































    properties(SetAccess={?mlreportgen.report.Chapter,?mlreportgen.report.ReporterBase})




































        Layout{mustBeInstanceOf(...
        'mlreportgen.report.ReporterLayout',Layout)}=[];
    end

    methods
        function chapter=Chapter(varargin)
            if nargin==1
                varargin=[{'Title'},varargin];
            end
            chapter=chapter@mlreportgen.report.Section(varargin{:});
            if isempty(chapter.OutlineLevel)
                chapter.OutlineLevel=1;
            end
            if isempty(chapter.Layout)
                chapter.Layout=mlreportgen.report.ReporterLayout(chapter);
            end
        end

        function title=getTitleReporter(chapter)





































































































            title=getTitleReporter@mlreportgen.report.Section(chapter);
            if isa(title,'mlreportgen.report.Title')
                title.Translations.NumberPrefixSuffix=chapter.getTranslations();
                title.Translations.Owner='Chapter';
            end
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.Section})
        function content=getTitle(section,report)



            if isa(section.Title,"mlreportgen.dom.Paragraph")...
                &&isempty(section.Title.StyleName)
                section.Title.StyleName="SectionTitle1";
            end
            content=getTitle@mlreportgen.report.Section(section,report);
        end

    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(reporter,rpt)%#ok<INUSL>
            reporterPath=mlreportgen.report.Section.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            reporterPath,rpt.Type);
        end
    end

    methods(Access=protected,Hidden)


        result=openImpl(reporter,impl,varargin)



        function is=isNumbered(chapter)


            is=isempty(chapter.Numbered)||chapter.Numbered;
        end

        function processHole(chapter,form,rpt)




            if strcmp(form.CurrentHoleId(1),'#')
                if~isempty(chapter.Layout)&&~isa(form,'mlreportgen.dom.PageHdrFtr')

                    resetPageNumber=getContext(rpt,'ResetPageNumberOnFirstChapter');
                    if isempty(resetPageNumber)||resetPageNumber

                        if isempty(chapter.Layout.FirstPageNumber)


                            if isempty(rpt.Layout.FirstPageNumber)
                                chapter.Layout.FirstPageNumber=1;
                            else
                                chapter.Layout.FirstPageNumber=...
                                rpt.Layout.FirstPageNumber;
                            end
                        end

                        setContext(rpt,'ResetPageNumberOnFirstChapter',false);
                    end

                    if~isempty(chapter.Layout)
                        updateLayout(chapter.Layout,rpt);
                    end
                    if~isempty(form.CurrentPageLayout)


                        plo.Form=form;
                        plo.Layout=form.CurrentPageLayout;
                        setContext(rpt,'ReporterLayout',plo);
                    end
                end
            else
                processHole@mlreportgen.report.Section(chapter,form,rpt);
            end
        end
    end

    methods(Static)
        function path=getClassFolder()



            [path]=fileparts(mfilename('fullpath'));
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.Chapter","mlreportgen.report.Section");
        end

        function number(rpt,value)







            mustBeNonempty(rpt);
            mustBeNonempty(value);
            mlreportgen.report.validators.mustBeReportBase(rpt);
            mlreportgen.report.validators.mustBeLogical(value);

            numbered=getContext(rpt,'OutlineLevelNumbered');
            numbered(1)=value;

            setContext(rpt,'OutlineLevelNumbered',numbered);
        end

        function translations=getTranslations()


            persistent INSTANCE;
            if isempty(INSTANCE)
                INSTANCE=mlreportgen.report.ReporterBase.parseTranslation(...
                mlreportgen.report.Chapter.getClassFolder(),...
                "ChapterTitleNumberPrefixSuffix.xml");
            end
            translations=INSTANCE;
        end

    end

end


function mustBeInstanceOf(varargin)
    mlreportgen.report.validators.mustBeInstanceOf(varargin{:});
end
