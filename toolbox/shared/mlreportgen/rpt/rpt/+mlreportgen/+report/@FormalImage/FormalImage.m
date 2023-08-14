classdef FormalImage<mlreportgen.report.Reporter





























































    properties




























        Image{mustBeImage(Image,"Image")}=[]






















































        Caption{mustBeBlock(Caption,"Caption")}=[]























        Width{mustBeDimension(Width)}=[]






















        Height{mustBeDimension(Height)}=[]
























        Map{mustBeDOMImageMap(Map)}=[]









        ScaleToFit{mustBeLogical}=true
    end

    properties(Access=private,Hidden=true)


        ShouldNumberTableHierarchically{mustBeLogical}=[]





        m_extraHeight="1in";


        m_extraWidth="0in";
    end

    methods

        function image=FormalImage(varargin)
            if(nargin==1)
                varargin=[{'Image'},varargin];
            end
            image=image@mlreportgen.report.Reporter(varargin{:});

            if isempty(image.TemplateName)
                image.TemplateName='FormalImage';
            end
        end

        function set.Image(image,value)
            if ischar(value)
                image.Image=string(value);
            else
                image.Image=value;
            end
        end

        function set.Caption(image,value)

            if ischar(value)
                image.Caption=string(value);
            else
                image.Caption=value;
            end
        end

        function reporter=getCaptionReporter(image)








            reporter=[];



            if isa(image.Caption,'mlreportgen.report.ReporterBase')
                reporter=image.Caption;
            end

            if isempty(reporter)
                reporter=mlreportgen.report.Title("Caption");
                reporter.Translations.Owner='FormalImage';
                reporter.Translations.NumberPrefixSuffix=image.getTranslations();
                reporter.Content=image.Caption;
                reporter.TemplateSrc=image;

                if image.ShouldNumberTableHierarchically
                    reporter.TemplateName='FormalImageHierNumberedCaption';
                else
                    reporter.TemplateName='FormalImageNumberedCaption';
                end
            end
        end

        function reporter=getImageReporter(image,report)







            reporter=[];



            if isa(image.Image,'mlreportgen.report.ReporterBase')
                reporter=image.Image;
            end

            if isempty(reporter)
                content=getDOMImage(image,image.Image,report);
                reporter=getInlineReporter(image,"Image",content);
            end
        end
        function appendCaption(image,newCaption)















            if isa(image.Caption,'mlreportgen.dom.Text')
                image.Caption=[image.Caption,mlreportgen.dom.Text(newCaption)];
            elseif mlreportgen.report.Reporter.isInlineContent(image.Caption)||...
                isa(image.Caption,'mlreportgen.report.HoleReporter')
                currentCaption="";
                currentCaption=getInlineCaptionContent(image,image.Caption,currentCaption);
                image.Caption=currentCaption+newCaption;
            elseif isa(image.Caption,'mlreportgen.dom.Paragraph')
                append(image.Caption,newCaption);
            else
                image.Caption=newCaption;
            end
        end

    end

    methods(Access={?mlreportgen.report.ReportForm,?mlreporten.report.FormalImage})

        function captionContent=getCaption(image,report)

            image.ShouldNumberTableHierarchically=isChapterNumberHierarchical(image,report);

            if mlreportgen.report.ReporterBase.isInlineContent(image.Caption)
                captionContent=getCaptionReporter(image);
            else
                captionContent=image.Caption;
            end
        end

        function content=getImage(image,report)
            if isstring(image.Image)
                if isValidImageExtension(image,image.Image,report.Type)
                    content=getImageReporter(image,report);
                else
                    error(message(...
                    "mlreportgen:report:error:invalidImageType",report.Type));
                end
            elseif isa(image.Image,'mlreportgen.dom.Image')
                if isValidImageExtension(image,image.Image.Path,report.Type)
                    content=getImageReporter(image,report);
                else
                    error(message(...
                    "mlreportgen:report:error:invalidDOMImageType",report.Type));
                end
            else
                content=image.Image;
            end
        end


    end

    methods(Access=protected,Hidden)


        result=openImpl(reporter,impl,varargin)

        function content=getInlineReporter(image,holeId,inline)
            content=mlreportgen.report.InlineContent(holeId);
            content.TemplateName="FormalImage"+holeId;
            content.TemplateSrc=image;
            content.Content=inline;
        end

        function valid=isValidImageExtension(image,imPath,type)%#ok<INUSL>
            [~,~,ext]=fileparts(imPath);


            ext=char(ext);
            valid=mlreportgen.dom.Document.isValidImageExt(type,ext(2:end));

        end

        function domImage=getDOMImage(image,imageSource,report)

            if isstring(imageSource)
                domImage=mlreportgen.dom.Image(imageSource);
            elseif isa(imageSource,'mlreportgen.dom.Image')
                domImage=imageSource;
            end

            resizeImage(image,domImage,report);
            if(~isempty(image.Map))
                domImage.Map=image.Map;
            end
        end
    end

    methods(Access=private)
        function inlineContent=getInlineCaptionContent(image,content,inlineContent)




            if isa(content,'mlreportgen.report.HoleReporter')
                inlineContent=getInlineCaptionContent(image,content.Content,inlineContent);
            elseif iscell(content)
                for i=1:numel(content)
                    inlineContent=getInlineCaptionContent(image,content{i},inlineContent);
                end
            else
                num=numel(content);
                if num>1
                    for i=1:num
                        inlineContent=getInlineCaptionContent(image,content(i),inlineContent);
                    end
                else
                    if ischar(content)||isstring(content)
                        inlineContent=inlineContent+string(content);
                    elseif isa(content,'mlreportgen.dom.Text')
                        inlineContent=inlineContent+content.Content;
                    end
                end
            end
        end

        function resizeImage(image,domImage,report)


            if image.ScaleToFit&&~(strcmp(report.Type,'html')||strcmp(report.Type,'html-file'))
                scaleImage(image,domImage,report);
            else
                units=mlreportgen.utils.units;

                domImageWidth=units.toPixels(domImage.Width);
                domImageHeight=units.toPixels(domImage.Height);



                if~isempty(image.Width)
                    domImage.Width=image.Width;
                else
                    if~isempty(image.Height)&&(domImageHeight~=0)
                        domImage.Width=strcat(num2str(units.toPixels(image.Height)*domImageWidth/domImageHeight),"px");
                    end
                end
                if~isempty(image.Height)
                    domImage.Height=image.Height;
                else
                    if~isempty(image.Width)&&(domImageWidth~=0)
                        domImage.Height=strcat(num2str(units.toPixels(image.Width)*domImageHeight/domImageWidth),"px");
                    end
                end
            end
        end

        function scaleImage(image,domImage,report)
            units=mlreportgen.utils.units;


            pageLayout=getReportLayout(report);

            if isempty(pageLayout)
                error(message("mlreportgen:report:error:pageLayoutNotFound"));
            end


            [pageBodyWidth,pageBodyHeight]=getPageBodySize(report);
            pageBodyWidth=pageBodyWidth-units.toInches(image.m_extraWidth);
            pageBodyHeight=pageBodyHeight-units.toInches(image.m_extraHeight);

            if pageBodyWidth<=0||pageBodyHeight<=0
                error(message("mlreportgen:report:error:invalidPageBodyArea"),pageBodyHeight,pageBodyWidth);
            end


            if~isempty(image.Height)
                height=units.toInches(image.Height);
            else
                height=units.toInches(domImage.Height);
            end

            if~isempty(image.Width)
                width=units.toInches(image.Width);
            else
                width=units.toInches(domImage.Width);
            end

            if width>pageBodyWidth
                scale=pageBodyWidth/width;
                width=pageBodyWidth;
                height=scale*height;
            end

            if height>pageBodyHeight
                scale=pageBodyHeight/height;
                height=pageBodyHeight;
                width=scale*width;
            end

            domImage.Height=[num2str(units.toPixels(height,'in')),'px'];
            domImage.Width=[num2str(units.toPixels(width,'in')),'px'];
        end
    end

    methods(Static)

        function path=getClassFolder()

            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)






            path=mlreportgen.report.FormalImage.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.FormalImage");
        end

        function translations=getTranslations()


            persistent INSTANCE;
            if isempty(INSTANCE)
                INSTANCE=mlreportgen.report.ReporterBase.parseTranslation(...
                mlreportgen.report.FormalImage.getClassFolder(),...
                "FormalImageCaptionNumberPrefixSuffix.xml");
            end
            translations=INSTANCE;
        end

    end

end


function mustBeDOMImageMap(map)
    mlreportgen.report.validators.mustBeInstanceOf(...
    'mlreportgen.dom.ImageMap',map);
end

function mustBeLogical(varargin)
    mlreportgen.report.validators.mustBeLogical(varargin{:});
end

function mustBeBlock(varargin)
    mlreportgen.report.validators.mustBeBlock(varargin{:});
end

function mustBeDimension(varargin)
    mlreportgen.report.validators.mustBeDimension(varargin{:});
end

function mustBeImage(varargin)
    mlreportgen.report.validators.mustBeImage(varargin{:});
end
