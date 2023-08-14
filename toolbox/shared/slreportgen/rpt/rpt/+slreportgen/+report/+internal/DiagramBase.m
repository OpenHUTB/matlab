classdef(Abstract,Hidden)DiagramBase<slreportgen.report.Reporter&...
    mlreportgen.report.mixin.SnapshotMaker






    properties













        SnapshotFormat{mustBeMember(SnapshotFormat,["auto","png","jpeg","bmp","tiff","emf","svg","pdf"])}="svg"









        Snapshot{mustBeFormalImage(Snapshot)}=mlreportgen.report.FormalImage



























































        Scaling{mustBeMember(Scaling,["auto","custom","zoom"])}="auto";
















        Height{mustBeNonEmptyString(Height)}="6in";
















        Width{mustBeNonEmptyString(Width)}="6.5in";







































        Zoom{mustBeNonEmptyString(Zoom)}="100%";

















        MaxHeight{mustBeNonEmptyString(MaxHeight)}="6in";

















        MaxWidth{mustBeNonEmptyString(MaxWidth)}="6.5in";
    end

    properties(Abstract,Constant,Access=protected)


ImageTemplateName



NumberedCaptionTemplateName



HierNumberedCaptionTemplateName
    end

    properties(Constant,Access=private)




        m_extraHeight="1in";


        m_extraWidth="0in";
    end

    methods
        function this=DiagramBase(varargin)
            if(nargin==1)
                args={"Source",varargin{1}};
            else
                args=varargin;
            end
            this=this@slreportgen.report.Reporter(args{:});

            if~mlreportgen.report.ReporterBase.isPropertySet("Snapshot",args)
                formalImage=mlreportgen.report.FormalImage;
                formalImage.ScaleToFit=false;
                this.Snapshot=formalImage;
            end
        end

        function image=getSnapshotImage(this,rpt)












            image=getSnapshotImageImpl(this,rpt,[]);
        end
    end

    methods(Abstract,Access=protected)


        snapObj=createSnapshotObject(this,varargin);


        createImageMap(this,rpt);
    end

    methods(Access={?mlreportgen.report.ReportForm})
        function content=getContent(this,rpt)



            currentLayout=getReportLayout(rpt);

            image=getSnapshotImageImpl(this,rpt,currentLayout);
            this.Snapshot.Image=image;



            if mlreportgen.report.Reporter.isInlineContent(this.Snapshot.Image)
                imageReporter=getImageReporter(this.Snapshot,rpt);
                imageReporter.TemplateSrc=this;
                imageReporter.TemplateName=this.ImageTemplateName;
                this.Snapshot.Image=imageReporter;
            end



            if~isempty(this.Snapshot.Caption)&&...
                mlreportgen.report.Reporter.isInlineContent(this.Snapshot.Caption)
                captionReporter=getCaptionReporter(this.Snapshot);
                captionReporter.TemplateSrc=this;

                if isChapterNumberHierarchical(this,rpt)
                    captionReporter.TemplateName=this.HierNumberedCaptionTemplateName;
                else
                    captionReporter.TemplateName=this.NumberedCaptionTemplateName;
                end
                this.Snapshot.Caption=captionReporter;
            end

            content=this.Snapshot;
        end
    end

    methods(Access=private)
        function image=getSnapshotImageImpl(this,rpt,pageLayout)



            if isempty(this.Source)
                error(message("slreportgen:report:error:noDiagramSpecified"));
            end

            if strcmp(this.SnapshotFormat,"auto")
                format="svg";
            else
                format=this.SnapshotFormat;
            end


            compileModel(rpt,this.Source);


            snapObj=createSnapshotObject(this,...
            "Filename",rpt.generateFileName(),...
            "Format",format);


            if strcmp(get_param(0,"EditorModernTheme"),"on")
                snapObj.Theme="Modern";
            else
                snapObj.Theme="Classic";
            end


            units=mlreportgen.utils.units;
            switch(this.Scaling)
            case "custom"

                snapObj.Scaling="Custom";

                diagWidth=units.toPixels(this.Width);
                diagHeight=units.toPixels(this.Height);
                snapObj.Size=[diagWidth,diagHeight];
            case "zoom"

                snapObj.Scaling="Zoom";
                snapObj.Zoom=str2double(...
                regexp(string(this.Zoom),"([0-9.]*)","tokens","once"));

                diagMaxWidth=units.toPixels(this.MaxWidth);
                diagMaxHeight=units.toPixels(this.MaxHeight);
                snapObj.MaxSize=[diagMaxWidth,diagMaxHeight];
            case "auto"


                snapObj.Scaling="Zoom";
                snapObj.Zoom=100;

                if strcmp(this.SnapshotFormat,"svg")||strcmp(this.SnapshotFormat,"pdf")



                    snapObj.MaxSize=[inf,inf];

                    if~isempty(pageLayout)
                        this.Snapshot.ScaleToFit=true;
                    end
                else
                    if~isempty(pageLayout)

                        [pageBodyWidth,pageBodyHeight]=getPageBodySize(rpt);

                        width=pageBodyWidth-units.toInches(this.m_extraWidth);
                        height=pageBodyHeight-units.toInches(this.m_extraHeight);

                        maxAvailablePageHeight=units.toPixels(height,'in');
                        maxAvailablePageWidth=units.toPixels(width,'in');

                        snapObj.MaxSize=[maxAvailablePageWidth,maxAvailablePageHeight];
                    else

                        snapObj.MaxSize=[inf,inf];
                    end
                end
            end

            image=snapObj.snap();

            if isempty(this.Snapshot.Map)
                this.Snapshot.Map=createImageMap(this,rpt);
            end
        end
    end
end



function mustBeFormalImage(snapshot)
    mustBeNonempty(snapshot);
    mlreportgen.report.validators.mustBeInstanceOf(...
    'mlreportgen.report.FormalImage',snapshot);
end

function mustBeNonEmptyString(value)
    mustBeNonempty(value);
    mlreportgen.report.validators.mustBeString(value);
end