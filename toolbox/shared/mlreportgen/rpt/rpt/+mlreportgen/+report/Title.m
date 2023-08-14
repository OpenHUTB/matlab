classdef Title<mlreportgen.report.HoleReporter

















































    properties












        Content{mlreportgen.report.validators.mustBeInline(Content)}=[];








        NumberPrefix=[];








        NumberSuffix=[];

















































        Translations=struct('NumberPrefixSuffix',[],'Content',[],'Owner',[]);
    end

    methods(Access={?mlreportgen.report.ReporterBase})
        function title=Title(varargin)
            title=title@mlreportgen.report.HoleReporter(varargin{:});
        end
    end

    methods
        function impl=getImpl(title,rpt)
            owner=title.Translations.Owner;
            if isempty(title.NumberPrefix)||isempty(title.NumberSuffix)
                translations=title.Translations.NumberPrefixSuffix;
                if~isempty(translations)



                    translation=title.getTranslation(translations,rpt.Locale);
                    if~isempty(translation)
                        if isempty(title.NumberPrefix)
                            title.NumberPrefix=translation.TitleNumberPrefix;
                        end

                        if isempty(title.NumberSuffix)
                            title.NumberSuffix=translation.TitleNumberSuffix;
                        end
                    end
                end
            end
            if isempty(title.Content)
                translations=title.Translations.Content;
                if~isempty(translations)
                    translation=title.getTranslation(translations,rpt.Locale);
                    if isempty(translation)
                        contentKey=sprintf('mlreportgen:report:title:default%sTitleContent',owner);
                        content=getString(message(contentKey));
                    else
                        content=translation.TitleContent;
                    end
                    if isempty(title.Content)
                        title.Content=content;
                    end
                end
            end

            impl=getImpl@mlreportgen.report.Reporter(title,rpt);
        end
    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end
    end
end
