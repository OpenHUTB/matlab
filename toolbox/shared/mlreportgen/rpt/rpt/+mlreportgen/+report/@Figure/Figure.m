classdef Figure<mlreportgen.report.MATLABGraphicsContainer











































































































    properties














        SnapshotFormat="svg"




        Source=[];































        Snapshot=mlreportgen.report.FormalImage;




























































































        Scaling="auto"
















        Height="6in";
















        Width="6.5in";







        PreserveBackgroundColor=false;
    end

    properties(Access=private,Hidden)


        ClonedFigureFile=[];





        UpdateToken=[];
    end

    properties(Constant,Access=protected)
        ImageTemplateName="FigureImage";
        NumberedCaptionTemplateName="FigureNumberedCaption";
        HierNumberedCaptionTemplateName="FigureHierNumberedCaption";
    end

    methods
        function figureReporter=Figure(varargin)
            if(nargin==1)
                varargin=[{"Source"},varargin];
            end

            figureReporter=...
            figureReporter@mlreportgen.report.MATLABGraphicsContainer(varargin{:});

            if isempty(figureReporter.TemplateName)
                figureReporter.TemplateName="Figure";
            end
        end

        function set.Source(figureReporter,value)
            if ischar(value)
                value=string(value);
            end

            figH=value;

            if isstring(value)

                [~,~,ext]=fileparts(value);
                if isempty(ext)
                    figFile=strcat(value,".fig");
                elseif strcmp(ext,".fig")||strcmp(ext,".mat")
                    figFile=value;
                else
                    error(message("mlreportgen:report:error:invalidFigure"));
                end

                figH=openfig(figFile,"invisible");
                c=onCleanup(@()delete(figH));
                figureReporter.Source=figFile;
            end


            while~isa(figH,'matlab.ui.Figure')
                figH=figH.Parent;
            end


            assert(~isempty(figH.Children),...
            message("mlreportgen:report:error:invalidFigure"));

            if~isstring(value)
                figureReporter.Source=figH;


                drawnow nocallbacks;
                figureReporter.UpdateToken=figH.UpdateToken;
            end

            createFigureClone(figureReporter);
        end


        function image=getSnapshotImage(figureReporter,report)











            image=getSnapshotImage@mlreportgen.report.MATLABGraphicsContainer(figureReporter,report);
        end
    end

    methods(Access=protected)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Access=protected)

        function figFile=getClonedFigureFile(figureReporter)











            drawnow nocallbacks;

            if(~isempty(figureReporter.Source)&&isgraphics(figureReporter.Source)...
                &&figureReporter.UpdateToken~=figureReporter.Source.UpdateToken)...
                ||(isempty(figureReporter.Source)&&~isempty(get(0,"CurrentFigure")))
                createFigureClone(figureReporter);
            end

            assert(~isempty(figureReporter.ClonedFigureFile),...
            message("mlreportgen:report:error:invalidFigure"));

            figFile=figureReporter.ClonedFigureFile;
        end
    end

    methods(Access=private)
        function figFile=createFigureClone(figureReporter)



            figH=[];
            if isempty(figureReporter.Source)

                figH=gcf();
            elseif isstring(figureReporter.Source)
                figFile=tempname+".fig";
                copyfile(figureReporter.Source,figFile);
            else
                figH=figureReporter.Source;
            end

            if~isempty(figH)


                figFile=tempname+".fig";
                hgsave(figH,figFile);
            end


            deleteClonedFigureFile(figureReporter);

            figureReporter.ClonedFigureFile=figFile;
        end
    end

    methods(Static,Hidden)
        function id=getLinkTargetID(figureHandle)


            id="figure_"+double(figureHandle)+"_"+figureHandle.Name+"_"+figureHandle.Tag;
            id=mlreportgen.utils.normalizeLinkID(id);
        end
    end

    methods(Static)
        function path=getClassFolder()

            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)





            path=mlreportgen.report.Figure.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "mlreportgen.report.Figure");
        end
    end
end
