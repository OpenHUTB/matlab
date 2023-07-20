classdef(Hidden,Abstract)Snapshot<handle&matlab.mixin.CustomDisplay









    properties(Abstract)
        Source;
    end

    properties





        Scaling(1,1)slreportgen.utils.internal.snapshot.Scaling="Zoom";




        Zoom(1,1)double{mustBeNonnegative}=100;





        MaxSize(1,2)double{mustBeNonnegative(MaxSize)}=[1000,1000];



        Size(1,2)double{mustBeNonnegative(Size)}=[200,200];






        Theme(1,1)slreportgen.utils.internal.snapshot.Theme="Modern";







        BackgroundColor(1,1)slreportgen.utils.internal.snapshot.BackgroundColor="MatchSource";



        ShowBadges(1,1)logical=true;










        Format(1,1)slreportgen.utils.internal.snapshot.Format="SVG";


        Filename(1,1)string="untitled";
    end

    properties(Hidden)
        Margins(1,4)double{mustBeNonnegative}=[0,0,0,0];
    end

    properties(Constant,Access=protected)
        PortalDPI=rptgen.utils.getScreenPixelsPerInch();
    end

    properties(Access=protected)
        GLUE2Portal;
        TargetOutputRect=[];
        TargetSceneRect=[];
        OutputSize=[];
        ImageFormatDPI;
    end

    methods
        function this=Snapshot(varargin)
            if~isempty(varargin)
                this.Source=varargin{1};
                n=numel(varargin);
                for i=2:2:n
                    this.(varargin{i})=varargin{i+1};
                end
            end
        end

        function fpath=snap(this)
            if isempty(this.Source)
                error(message("slreportgen:utils:Snapshot:SourceNotSpecified"));
            end




            [fdir,fname,fext]=fileparts(this.Filename);
            if(strlength(fext)==0)
                fext=fileExtension(this.Format);
            end
            fpath=fullfile(fdir,strcat(fname,fext));
            fpath=string(mlreportgen.utils.internal.canonicalPath(fpath));

            folder=fileparts(fpath);
            if~isfolder(folder)
                mkdir(folder);
            end

            targetSceneRect=getTargetSceneRect(this);
            targetOutputRect=getTargetOutputRect(this);
            outputSize=getOutputSize(this);


            this.ImageFormatDPI=getImageFormatDPI(this);
            scale=this.ImageFormatDPI/this.PortalDPI;
            outputSize=outputSize*scale;
            targetOutputRect(3:4)=targetOutputRect(3:4)*scale;

            this.TargetOutputRect=targetOutputRect;
            this.TargetSceneRect=targetSceneRect;
            this.OutputSize=outputSize;

            portal=this.GLUE2Portal;
            portal.theme=char(this.Theme);
            portal.suppressBadges=~this.ShowBadges;

            portal.targetSceneRect=targetSceneRect;
            portal.targetOutputRect=targetOutputRect;
            portal.targetOverlayRect=targetOutputRect;
            portal.targetScene.Background.Color=getTargetBackgroundColor(this);

            opts=portal.exportOptions;
            opts.centerWithAspectRatioForSpecifiedSize=false;
            opts.colorMode='Color';

            switch(this.BackgroundColor)
            case "MatchSource"
                colormode='MatchCanvas';
            case "White"
                colormode='White';
            case "Transparent"
                colormode='Transparent';
            end
            opts.backgroundColorMode=colormode;

            opts.sizeMode='UseSpecifiedSize';
            opts.size=outputSize;
            opts.format=char(this.Format);
            opts.fileName=char(fpath);

            export(portal);
        end
    end

    methods(Abstract,Access=protected)
        targetSceneRect=getSpecifiedTargetSceneRect(this)
        backgroundColor=getTargetBackgroundColor(this)
    end

    methods(Access=protected)
        function resetGLUE2Portal(this,target,context)
            portal=GLUE2.Portal();
            portal.pathXStyle=get_param(0,"EditorPathXStyle");
            portal.targetContext=context;

            if~isempty(target)
                if isa(target,"Stateflow.Object")
                    portal.enableTargetBoundsCache=false;
                    portal.setTarget('Stateflow',target);
                else
                    portal.enableTargetBoundsCache=true;
                    portal.setTarget('Simulink',target);
                end
            end

            this.GLUE2Portal=portal;
            this.TargetOutputRect=[];
            this.TargetSceneRect=[];
            this.OutputSize=[];
        end

        function outputRect=sceneRectToOutputRect(this,sceneRect)
            targetOutputRect=this.TargetOutputRect;
            targetSceneRect=this.TargetSceneRect;
            outputSize=this.OutputSize;
            if isempty(targetOutputRect)
                targetOutputRect=getTargetOutputRect(this);
                targetSceneRect=getTargetSceneRect(this);
                outputSize=getOutputSize(this);
            end

            scale=targetOutputRect(3)/targetSceneRect(3);
            offset=targetOutputRect(1:2)-scale*(targetSceneRect(1:2));
            rect=scale*(sceneRect)+[offset,0,0];

            top=max(0,rect(2));
            left=max(0,rect(1));
            right=rect(1)+rect(3);
            bottom=rect(2)+rect(4);

            if(right>outputSize(1))
                right=outputSize(1);
            end
            width=right-left;

            if(bottom>outputSize(2))
                bottom=outputSize(2);
            end
            height=bottom-top;

            if(width<0)||(height<0)
                outputRect=[];
            else
                outputRect=[left,top,width,height];
            end
        end

        function dpi=getImageFormatDPI(this)

            if strcmp(this.Format,"PDF")||(ismac()&&strcmp(this.Format,"SVG"))
                dpi=72;
            else
                dpi=this.PortalDPI;
            end
        end
    end

    methods(Access=private)
        function targetSceneRect=getTargetSceneRect(this)
            sceneRect=getSpecifiedTargetSceneRect(this);

            targetAspect=sceneRect(3)/sceneRect(4);
            switch this.Scaling
            case "Zoom"
                outputAspect=targetAspect;

            case "Custom"
                margins=this.Margins;
                outputSize=this.Size;
                outputAspect=(outputSize(1)-margins(1)-margins(3))...
                /(outputSize(2)-margins(2)-margins(4));
            end

            if(targetAspect>outputAspect)
                scale=targetAspect/outputAspect;
                offset=(scale*sceneRect(4)-sceneRect(4))/2;
                targetSceneRect=[...
                sceneRect(1),...
                sceneRect(2)-offset,...
                sceneRect(3),...
                scale*sceneRect(4)];
            else
                scale=outputAspect/targetAspect;
                offset=(scale*sceneRect(3)-sceneRect(3))/2;
                targetSceneRect=[...
                sceneRect(1)-offset,...
                sceneRect(2),...
                scale*sceneRect(3),...
                sceneRect(4)];
            end
        end

        function targetOutputRect=getTargetOutputRect(this)
            switch this.Scaling
            case "Zoom"
                targetSceneRect=getTargetSceneRect(this);
                scale=this.Zoom/100;
                maxOutputSize=this.MaxSize;
                outputSize=scale*targetSceneRect(3:4);

                scale=1;
                if any(outputSize>maxOutputSize)
                    scale=maxOutputSize(1)/outputSize(1);
                end
                outputSize=scale*outputSize;

            case "Custom"
                outputSize=this.Size;
            end

            margins=this.Margins;
            targetOutputRect=[
            margins(1),...
            margins(2),...
            outputSize(1),...
            outputSize(2)...
            ];
        end

        function outputSize=getOutputSize(this)
            margins=this.Margins;
            targetOutputRect=getTargetOutputRect(this);
            outputSize=[
            targetOutputRect(3)+margins(1)+margins(3),...
            targetOutputRect(4)+margins(2)+margins(4)...
            ];
        end
    end
end

