classdef Section<mlreportgen.report.Reporter


























































    properties

















































































        Title{mustBeBlock(Title,"Title")}=[]










        Numbered{mustBeLogical(Numbered)}=[];
    end

    properties(SetAccess={?mlreportgen.report.ReporterBase})



















        Content={};
    end

    properties(Hidden=true)

        OutlineLevel=[];
    end

    methods
        function section=Section(varargin)
            content=[];
            if nargin==1
                varargin=[{'Title'},varargin];
            else

                idx=mlreportgen.report.ReporterBase.getPropertySetIdx(...
                "Content",varargin);
                if~isempty(idx)

                    content=varargin{idx+1};

                    varargin(idx:idx+1)=[];
                end

            end
            section=section@mlreportgen.report.Reporter(varargin{:});

            if isempty(section.TemplateName)
                section.TemplateName='Section';
            end

            if~isempty(content)
                add(section,content);
            end
        end

        function append(section,content)




            if isempty(section.Impl)
                if~isempty(content)
                    section.Content{end+1}=content;
                end
            else
                error(message(...
                "mlreportgen:report:error:cannotAddMoreContent"));
            end
        end

        function add(section,content)










            append(section,content)
        end

        function impl=getImpl(section,rpt)


            level=getContext(rpt,'OutlineLevel');
            if isempty(level)
                level=0;
            end

            level=level+1;
            setContext(rpt,'OutlineLevel',level);
            setContext(rpt,sprintf('Section%d',level),section);


            if isempty(section.OutlineLevel)
                section.OutlineLevel=level;
            end

            if isempty(section.Numbered)
                numbered=getContext(rpt,'OutlineLevelNumbered');
                if level>6
                    section.Numbered=false;
                else
                    if~isempty(numbered)&&numel(numbered)>=level
                        section.Numbered=numbered(level);
                    else
                        section.Numbered=true;
                    end
                end
            end


            impl=getImpl@mlreportgen.report.Reporter(section,rpt);

            setContext(rpt,sprintf('Section%d',level),[]);

            level=level-1;
            setContext(rpt,'OutlineLevel',level);
        end

        function title=getTitleReporter(section)








































































































            title=[];
            if isa(section.Title,'mlreportgen.report.ReporterBase')
                title=section.Title;
            end
            if isempty(title)



                title=mlreportgen.report.SectionTitle("Title");
                title.Content=section.Title;
                if isNumbered(section)
                    title.TemplateName='SectionNumberedTitle';
                    if isempty(title.NumberSuffix)


                        title.NumberSuffix=mlreportgen.dom.Text(". ");
                        title.NumberSuffix.WhiteSpace="preserve";
                    end
                else
                    title.TemplateName='SectionTitle';
                end
                title.TemplateSrc=section;
                title.OutlineLevel=section.OutlineLevel;
            end
        end
    end

    methods(Access=protected,Hidden)


        result=openImpl(reporter,impl,varargin)

        function updateImplTemplateName(section)
            level=section.OutlineLevel;
            if isempty(level)
                level=1;
            end
            if level>6
                level=6;
            end
            section.Impl.TemplateName=strcat(section.TemplateName,num2str(level));
        end

        function processHole(section,form,rpt)

            if strcmp(form.CurrentHoleId(1),'#')
                if~isa(form,'mlreportgen.dom.PageHdrFtr')
                    fillHeadersFooters(section,form,rpt);
                end
            else
                if strcmp(form.CurrentHoleId,'Content')







                    if isempty(form.CurrentPageLayout)



                        plo=getContext(rpt,'ReporterLayout');
                        if~isempty(plo)


                            plo.Form=form;
                            setContext(rpt,'ReporterLayout',plo);
                        end
                        fillHole(section,form,rpt);
                    else
                        plo.Form=form;
                        plo.Layout=form.CurrentPageLayout;
                        setContext(rpt,'ReporterLayout',plo);
                        fillHole(section,form,rpt);
                        removeContext(rpt,'ReporterLayout');
                    end
                else
                    fillHole(section,form,rpt);
                end
            end
        end

        function is=isNumbered(section)

            is=isempty(section.Numbered)||section.Numbered;
        end

    end

    methods(Static)
        function path=getClassFolder()

            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)






            path=mlreportgen.report.Section.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)













            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.Section");
        end

        function number(rpt,value)























            mustBeNonempty(rpt);
            mustBeNonempty(value);
            mlreportgen.report.validators.mustBeReportBase(rpt);
            mlreportgen.report.validators.mustBeLogical(value);

            setContext(rpt,'OutlineLevelNumbered',...
            [value,value,value,value,value,value]);
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.Section})
        function content=getTitle(section,report)%#ok<INUSD>
            if mlreportgen.report.ReporterBase.isInlineContent(section.Title)
                content=getTitleReporter(section);
            else
                content=section.Title;
                if isa(content,"mlreportgen.report.ReporterBase")...
                    &&isempty(content.OutlineLevel)
                    content.OutlineLevel=section.OutlineLevel;
                end
            end
        end

    end

end


function mustBeBlock(varargin)
    mlreportgen.report.validators.mustBeBlock(varargin{:});
end
function mustBeLogical(varargin)
    mlreportgen.report.validators.mustBeLogical(varargin{:});
end
