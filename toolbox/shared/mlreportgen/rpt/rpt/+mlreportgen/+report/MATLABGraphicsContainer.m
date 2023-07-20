classdef(Abstract,Hidden)MATLABGraphicsContainer<mlreportgen.report.Reporter&...
    mlreportgen.report.mixin.SnapshotMaker





    properties(Abstract)
        SnapshotFormat{mustBeMember(SnapshotFormat,["auto","png","emf","tif","tiff","bmp","jpeg","jpg","svg","pdf"])};
        Source{mustBeValidSource(Source)};
        Snapshot{mustBeFormalImage(Snapshot)};
        Scaling{mustBeMember(Scaling,["auto","custom","none"])};
        Height{mustBeNonEmptyString(Height)};
        Width{mustBeNonEmptyString(Width)};
        PreserveBackgroundColor{mustBeLogical(PreserveBackgroundColor)};
    end

    properties(Abstract,Constant,Access=protected)


ImageTemplateName



NumberedCaptionTemplateName



HierNumberedCaptionTemplateName
    end

    properties(Access=public,Hidden)




        ExtraHeight="1in";


        ExtraWidth="0in";
    end

    properties(Access=private,Hidden)


        ClonedFigureFile;
    end

    properties(Access=private,Constant)

        FormatToDevice=struct(...
        'png','png',...
        'emf','meta',...
        'tif','tiff',...
        'tiff','tiff',...
        'bmp','bmp',...
        'jpeg','jpeg',...
        'jpg','jpeg',...
        'svg','svg',...
        'pdf','pdf');
    end

    methods
        function this=MATLABGraphicsContainer(varargin)
            if(nargin==1)
                varargin=[{"Source"},varargin];
            end
            this=...
            this@mlreportgen.report.Reporter(varargin{:});
            if~mlreportgen.report.ReporterBase.isPropertySet("Snapshot",varargin)
                formalImage=mlreportgen.report.FormalImage();
                formalImage.ScaleToFit=false;
                this.Snapshot=formalImage;
            end

        end

        function image=getSnapshotImage(this,report)










            image=getSnapshotImageImpl(this,report,[]);

            if isa(image,"mlreportgen.dom.Image")
                image=string(image.Path);
            end
        end

        function delete(this)
            deleteClonedFigureFile(this)
        end
    end

    methods(Access=protected,Hidden)
        function deleteClonedFigureFile(this)

            if~isempty(this.ClonedFigureFile)&&isfile(this.ClonedFigureFile)
                delete(this.ClonedFigureFile);
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm})
        function content=getContent(this,report)
            pageLayout=getReportLayout(report);
            if~isa(this.Snapshot.Image,'mlreportgen.report.ReporterBase')
                img=getSnapshotImageImpl(this,report,pageLayout);
                this.Snapshot.Image=img;
            end



            if mlreportgen.report.Reporter.isInlineContent(this.Snapshot.Image)
                imageReporter=getImageReporter(this.Snapshot,report);
                imageReporter.TemplateSrc=this;
                imageReporter.TemplateName=this.ImageTemplateName;
                this.Snapshot.Image=imageReporter;
            end



            shouldNumberAxesHierarchically=isChapterNumberHierarchical(this,report);

            if~isempty(this.Snapshot.Caption)&&...
                mlreportgen.report.Reporter.isInlineContent(this.Snapshot.Caption)
                captionReporter=getCaptionReporter(this.Snapshot);
                captionReporter.TemplateSrc=this;

                if shouldNumberAxesHierarchically
                    captionReporter.TemplateName=this.HierNumberedCaptionTemplateName;
                else
                    captionReporter.TemplateName=this.NumberedCaptionTemplateName;
                end
                this.Snapshot.Caption=captionReporter;
            end

            content=this.Snapshot;
        end
    end

    methods(Access=protected)
        function content=getSnapshotImageImpl(this,rpt,pageLayout)
            imgformat=getImageFormat(this);

            figFile=this.getClonedFigureFile();

            snapShotFigure=openfig(figFile,"invisible");
            scopedDelete=onCleanup(@()delete(snapShotFigure));


            snapShotFigure.PaperUnits="inches";
            if this.PreserveBackgroundColor
                snapShotFigure.InvertHardcopy='off';
            else
                snapShotFigure.InvertHardcopy='on';
            end


            [newWidth,newHeight]=getSnapshotDimensions(this,rpt,pageLayout,snapShotFigure);

            if newWidth>0&&newHeight>0
                snapShotFigure.PaperPositionMode="manual";
                snapShotFigure.PaperUnits="inches";
                snapShotFigure.PaperPosition=[0,0,newWidth,newHeight];
                snapShotFigure.PaperSize=[newWidth,newHeight];
            end

            format=this.FormatToDevice.(imgformat);
            device=strcat("-d",format);

            tempImageFile=rpt.generateFileName(imgformat);
            resolutionArg=['-r ',num2str(rptgen.utils.getScreenPixelsPerInch())];

            print(snapShotFigure,device,tempImageFile,resolutionArg);
            domImage=mlreportgen.dom.Image(tempImageFile);

            if~strcmp(this.Scaling,'none')&&...
                (strcmp(imgformat,'svg')||strcmp(imgformat,'emf'))






                if ispc()
                    scale=1/mlreportgen.utils.internal.getDPIScale();
                else
                    scale=1;
                end

                if(scale~=1)

                    heightValue=extract(string(domImage.Height),digitsPattern);
                    heightUnit=extract(string(domImage.Height),lettersPattern);
                    domImage.Height=strcat(num2str(str2double(heightValue)*scale),...
                    heightUnit);


                    widthValue=extract(string(domImage.Width),digitsPattern);
                    widthUnit=extract(string(domImage.Width),lettersPattern);
                    domImage.Width=strcat(num2str(str2double(widthValue)*scale),...
                    widthUnit);
                end
            end

            content=domImage;
        end

        function format=getImageFormat(this,varargin)
            if strcmp(this.SnapshotFormat,"auto")
                this.SnapshotFormat="svg";
            end
            format=this.SnapshotFormat;
        end

        function[newWidth,newHeight]=getSnapshotDimensions(this,rpt,pageLayout,snapShotFigure)





            units=mlreportgen.utils.units;

            switch this.Scaling
            case 'custom'

                newHeight=units.toInches(this.Height);
                newWidth=units.toInches(this.Width);
            case 'auto'
                if isempty(pageLayout)
                    pos=snapShotFigure.Position;
                    maxWidth=units.toInches(pos(3),snapShotFigure.Units);
                    maxHeight=units.toInches(pos(4),snapShotFigure.Units);
                else
                    [pageBodyWidth,pageBodyHeight]=getPageBodySize(rpt);
                    maxWidth=pageBodyWidth-units.toInches(this.ExtraWidth);
                    maxHeight=pageBodyHeight-units.toInches(this.ExtraHeight);
                end

                position=snapShotFigure.Position;
                figHeight=position(4);
                figWidth=position(3);

                dstAspect=maxWidth/maxHeight;
                srcAspect=figWidth/figHeight;
                if(srcAspect>dstAspect)
                    scale=maxWidth/figWidth;
                else
                    scale=maxHeight/figHeight;
                end

                newHeight=scale*figHeight;
                newWidth=scale*figWidth;
            otherwise
                newHeight=-1;
                newWidth=-1;
            end
        end
    end

    methods(Access=protected,Abstract)

        matlabGraphicsContainerH=getClonedFigureFile(reporter)
    end
end




function mustBeValidSource(source)
    if ischar(source)
        source=string(source);
    end


    validGraphicsContainer=(isnumeric(source)&&isempty(source))||...
    (isstring(source)&&source~="")||(isscalar(source)&&ishghandle(source));

    if(~validGraphicsContainer)
        error(message("mlreportgen:report:error:invalidFigure"));
    end
end

function mustBeFormalImage(snapshot)

    mustBeNonempty(snapshot);
    mlreportgen.report.validators.mustBeInstanceOf('mlreportgen.report.FormalImage',snapshot);
end

function mustBeNonEmptyString(val)
    mustBeNonempty(val);
    mlreportgen.report.validators.mustBeString(val);
end

function mustBeLogical(val)
    mlreportgen.report.validators.mustBeSingleValue(val);
end
