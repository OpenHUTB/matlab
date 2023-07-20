classdef(Abstract)rptgen_cform_page_layout<mlreportgen.rpt2api.ComponentConverter






























    methods(Abstract,Access=protected)



        getDOMClassName(this);
    end

    methods(Access=protected)

        function write(this)
            import mlreportgen.rpt2api.exprstr.Parser



            writeStartBanner(this);

            layoutVarName=getVariableName(this);
            fprintf(this.FID,"%s = %s;\n",layoutVarName,getDOMClassName(this));



            this.RptFileConverter.CurrentLayoutObject=layoutVarName;


            firstPageNum=this.Component.FirstPageNum;
            if strcmp(this.Component.FirstPageNumType,"specify")&&~isempty(firstPageNum)
                fprintf(this.FID,"%s.FirstPageNumber = %d;\n",layoutVarName,firstPageNum);
            end


            pageNumFormat=this.Component.PageNumFormat;
            if~strcmp(pageNumFormat,"none")
                pageNumFormatDOMValue=[];
                switch pageNumFormat
                case 'upAlpha'
                    pageNumFormatDOMValue="A";
                case "upRoman"
                    pageNumFormatDOMValue="I";
                case{"a","i","n"}
                    pageNumFormatDOMValue=pageNumFormat;
                end
                fprintf(this.FID,'%s.PageNumberFormat = "%s";\n',layoutVarName,pageNumFormatDOMValue);
            end


            sectionBreak=this.Component.SectionBreak;
            sectionBreakDOMValue=[];
            switch sectionBreak
            case "same"
                sectionBreakDOMValue="Same Page";
            case "next"
                sectionBreakDOMValue="Next Page";
            case "odd"
                sectionBreakDOMValue="Odd Page";
            case "even"
                sectionBreakDOMValue="Even Page";
            end
            fprintf(this.FID,'%s.SectionBreak = "%s";\n',layoutVarName,sectionBreakDOMValue);


            if strcmp(this.Component.PageMargin,"specify")
                fprintf(this.FID,'%s.PageMargins.Top = "%s";\n',layoutVarName,this.Component.TopMargin);
                fprintf(this.FID,'%s.PageMargins.Bottom = "%s";\n',layoutVarName,this.Component.BottomMargin);
                fprintf(this.FID,'%s.PageMargins.Left = "%s";\n',layoutVarName,this.Component.LeftMargin);
                fprintf(this.FID,'%s.PageMargins.Right = "%s";\n',layoutVarName,this.Component.RightMargin);
                fprintf(this.FID,'%s.PageMargins.Header = "%s";\n',layoutVarName,this.Component.HeaderMargin);
                fprintf(this.FID,'%s.PageMargins.Footer = "%s";\n',layoutVarName,this.Component.FooterMargin);
                fprintf(this.FID,'%s.PageMargins.Gutter = "%s";\n',layoutVarName,this.Component.GutterMargin);
            end


            if strcmp(this.Component.PageSize,"specify")
                fprintf(this.FID,'%s.PageSize.Height = "%s";\n',layoutVarName,this.Component.Height);
                fprintf(this.FID,'%s.PageSize.Width = "%s";\n',layoutVarName,this.Component.Width);
                fprintf(this.FID,'%s.PageSize.Orientation = "%s";\n',layoutVarName,this.Component.Orientation);
            end


            waterMarkFile=this.Component.FileName;
            if~isempty(waterMarkFile)
                filePath=mlreportgen.utils.findFile(waterMarkFile);
                if isempty(filePath)

                    template=mlreportgen.rpt2api.rptgen_cform_page_layout.getTemplate('watermarkFileNotFound');
                    fprintf(this.FID,template,waterMarkFile,class(this.Component));
                else
                    fprintf(this.FID,'rptPageLayoutWaterMark = Watermark("%s");\n',filePath);

                    if strcmp(this.Component.Scale,"specify")
                        imageHeight=this.Component.ImageHeight;
                        if~isempty(imageHeight)
                            fprintf(this.FID,'rptPageLayoutWaterMark.Height = "%s";\n',imageHeight);
                        end

                        imageWidth=this.Component.ImageWidth;
                        if~isempty(imageWidth)
                            fprintf(this.FID,'rptPageLayoutWaterMark.Width = "%s";\n',imageWidth);
                        end
                    end

                    fprintf(this.FID,'%s.Watermark = rptPageLayoutWaterMark;\n',layoutVarName);
                end
            end
        end

        function convertComponentChildren(this)


            convertHeadersAndFooters(this);


            parentName=this.RptFileConverter.VariableNameStack.top;
            fprintf(this.FID,"append(%s,%s);\n\n",...
            parentName,getVariableName(this));



            writeEndBanner(this);
        end

        function name=getVariableRootName(this)





            name=strcat("rpt",getDOMClassName(this));
        end

    end

    methods(Access=private)

        function convertHeadersAndFooters(this)

            layoutVarName=getVariableName(this);
            children=getComponentChildren(this);
            nChildren=numel(children);
            for iChild=1:nChildren
                hdrFtrCmpn=children{iChild};
                hdrFtrConverter=getConverter(this.RptFileConverter.ConverterFactory,...
                hdrFtrCmpn,this.RptFileConverter);
                if isa(hdrFtrCmpn,"rptgen.cform_page_header")
                    hdrFtrConverter.AssignTo=sprintf("%s.PageHeaders",layoutVarName);
                elseif isa(hdrFtrCmpn,"rptgen.cform_page_footer")
                    hdrFtrConverter.AssignTo=sprintf("%s.PageFooters",layoutVarName);
                end
                convert(hdrFtrConverter);
            end
        end

    end

    methods(Static)

        function folder=getClassFolder()
            folder=fileparts(mfilename('fullpath'));
        end

        function template=getTemplate(templateName)
            import mlreportgen.rpt2api.rptgen_cform_page_layout
            templateFolder=fullfile(rptgen_cform_page_layout.getClassFolder,...
            'templates');
            templatePath=fullfile(templateFolder,[templateName,'.txt']);
            template=fileread(templatePath);
        end

    end

end
