classdef(Abstract,Hidden)Layout<matlab.mixin.SetGet&matlab.mixin.Copyable













    properties

















        Watermark{mlreportgen.report.validators.mustBeWatermark(Watermark)}=[]







































        FirstPageNumber{mustBeNumeric}=[]
















        PageNumberFormat{mlreportgen.report.validators.mustBeString}=[]





        Landscape{mlreportgen.report.validators.mustBeLogical}=[]






















        PageSize{mlreportgen.report.validators.mustBeInstanceOf(...
        'mlreportgen.dom.PageSize',PageSize)}=[]



























        PageMargins{mlreportgen.report.validators.mustBeInstanceOf(...
        'mlreportgen.dom.PageMargins',PageMargins)}=[]





















        PageBorder{mlreportgen.report.validators.mustBeInstanceOf(...
        'mlreportgen.dom.PageBorder',PageBorder)}=[]

    end

    properties(SetAccess={?mlreportgen.report.Layout,?mlreportgen.report.ReporterBase})

        Owner=[];
    end

    methods
        function layout=Layout(owner)
            layout.Owner=owner;
        end
    end

    methods(Access=protected)
        function fillHeadersFooters(layout,form,rpt)
            fillHeadersFooters(layout.Owner,form,rpt);
        end

        function updatePageLayout(layout,form,reportLayout)

            settings=struct(...
            'Watermark',layout.Watermark,...
            'FirstPageNumber',layout.FirstPageNumber,...
            'PageNumberFormat',layout.PageNumberFormat,...
            'Landscape',layout.Landscape,...
            'PageSize',layout.PageSize,...
            'PageMargins',layout.PageMargins,...
            'PageBorder',layout.PageBorder);

            if nargin>2
                if isempty(settings.Watermark)
                    settings.Watermark=reportLayout.Watermark;
                end
                if isempty(settings.FirstPageNumber)
                    settings.FirstPageNumber=reportLayout.FirstPageNumber;
                end
                if isempty(settings.PageNumberFormat)
                    settings.PageNumberFormat=reportLayout.PageNumberFormat;
                end
                if isempty(settings.Landscape)
                    settings.Landscape=reportLayout.Landscape;
                end
                if isempty(settings.PageSize)
                    settings.PageSize=reportLayout.PageSize;
                end
                if isempty(settings.PageMargins)
                    settings.PageMargins=reportLayout.PageMargins;
                end
                if isempty(settings.PageBorder)
                    settings.PageBorder=reportLayout.PageBorder;
                end
            end

            if~isempty(settings.Watermark)
                if isa(settings.Watermark,'mlreportgen.dom.Watermark')
                    form.CurrentPageLayout.Watermark=settings.Watermark;
                else
                    form.CurrentPageLayout.Watermark=...
                    mlreportgen.dom.Watermark(settings.Watermark);
                end
            end




            if settings.FirstPageNumber<0
                settings.FirstPageNumber=[];
            end




            currentPageNumFormat=[];
            if~isempty(form.CurrentPageLayout.PageNumberFormat)
                currentPageNumFormat=form.CurrentPageLayout.PageNumberFormat;
            end

            form.CurrentPageLayout.FirstPageNumber=settings.FirstPageNumber;


            if~isempty(currentPageNumFormat)
                form.CurrentPageLayout.PageNumberFormat=currentPageNumFormat;
            end

            if~isempty(settings.PageNumberFormat)
                form.CurrentPageLayout.PageNumberFormat=settings.PageNumberFormat;
            end




            if~isempty(settings.PageSize)
                form.CurrentPageLayout.PageSize.Height=settings.PageSize.Height;
                form.CurrentPageLayout.PageSize.Width=settings.PageSize.Width;
                form.CurrentPageLayout.PageSize.Orientation=settings.PageSize.Orientation;
            end
            if~isempty(settings.PageMargins)
                form.CurrentPageLayout.PageMargins.Top=settings.PageMargins.Top;
                form.CurrentPageLayout.PageMargins.Bottom=settings.PageMargins.Bottom;
                form.CurrentPageLayout.PageMargins.Left=settings.PageMargins.Left;
                form.CurrentPageLayout.PageMargins.Right=settings.PageMargins.Right;
                form.CurrentPageLayout.PageMargins.Header=settings.PageMargins.Header;
                form.CurrentPageLayout.PageMargins.Footer=settings.PageMargins.Footer;
                form.CurrentPageLayout.PageMargins.Gutter=settings.PageMargins.Gutter;
            end

            if~isempty(settings.Landscape)
                currentIsLandscape=strcmp(...
                form.CurrentPageLayout.PageSize.Orientation,'landscape');
                if currentIsLandscape~=settings.Landscape
                    w=form.CurrentPageLayout.PageSize.Width;
                    form.CurrentPageLayout.PageSize.Width=...
                    form.CurrentPageLayout.PageSize.Height;
                    form.CurrentPageLayout.PageSize.Height=w;
                    if currentIsLandscape
                        form.CurrentPageLayout.PageSize.Orientation='portrait';
                    else
                        form.CurrentPageLayout.PageSize.Orientation='landscape';
                    end
                end
            end

            if~isempty(settings.PageBorder)
                form.CurrentPageLayout.PageBorder=mlreportgen.dom.PageBorder;
                form.CurrentPageLayout.PageBorder.Style=settings.PageBorder.Style;
                form.CurrentPageLayout.PageBorder.Color=settings.PageBorder.Color;
                form.CurrentPageLayout.PageBorder.Width=settings.PageBorder.Width;
                form.CurrentPageLayout.PageBorder.Margin=settings.PageBorder.Margin;
                form.CurrentPageLayout.PageBorder.MeasureFrom=settings.PageBorder.MeasureFrom;
                form.CurrentPageLayout.PageBorder.SurroundHeader=settings.PageBorder.SurroundHeader;
                form.CurrentPageLayout.PageBorder.SurroundFooter=settings.PageBorder.SurroundFooter;
                form.CurrentPageLayout.PageBorder.TopStyle=settings.PageBorder.TopStyle;
                form.CurrentPageLayout.PageBorder.TopColor=settings.PageBorder.TopColor;
                form.CurrentPageLayout.PageBorder.TopWidth=settings.PageBorder.TopWidth;
                form.CurrentPageLayout.PageBorder.TopMargin=settings.PageBorder.TopMargin;
                form.CurrentPageLayout.PageBorder.LeftStyle=settings.PageBorder.LeftStyle;
                form.CurrentPageLayout.PageBorder.LeftColor=settings.PageBorder.LeftColor;
                form.CurrentPageLayout.PageBorder.LeftWidth=settings.PageBorder.LeftWidth;
                form.CurrentPageLayout.PageBorder.LeftMargin=settings.PageBorder.LeftMargin;
                form.CurrentPageLayout.PageBorder.BottomStyle=settings.PageBorder.BottomStyle;
                form.CurrentPageLayout.PageBorder.BottomColor=settings.PageBorder.BottomColor;
                form.CurrentPageLayout.PageBorder.BottomWidth=settings.PageBorder.BottomWidth;
                form.CurrentPageLayout.PageBorder.BottomMargin=settings.PageBorder.BottomMargin;
                form.CurrentPageLayout.PageBorder.RightStyle=settings.PageBorder.RightStyle;
                form.CurrentPageLayout.PageBorder.RightColor=settings.PageBorder.RightColor;
                form.CurrentPageLayout.PageBorder.RightWidth=settings.PageBorder.RightWidth;
                form.CurrentPageLayout.PageBorder.RightMargin=settings.PageBorder.RightMargin;
            end

        end
    end


end

