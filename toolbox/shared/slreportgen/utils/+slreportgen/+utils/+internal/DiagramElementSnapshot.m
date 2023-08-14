classdef(Hidden)DiagramElementSnapshot<slreportgen.utils.internal.Snapshot







































    properties(Dependent)




        Source;
    end

    properties(Access=private)
        SpecifiedSource=[];
        ResolvedSource=[];
        SourceBounds=[];
    end

    methods
        function this=DiagramElementSnapshot(varargin)
            this=this@slreportgen.utils.internal.Snapshot(varargin{:});
        end

        function set.Source(this,source)
            if~isempty(source)
                objH=slreportgen.utils.getSlSfHandle(source);
                if isa(objH,"Stateflow.Chart")
                    objH=get_param(objH.Path,'Handle');
                end

                if(isValidSlObject(slroot,objH)&&objH==bdroot(objH))
                    error(message("slreportgen:utils:Snapshot:InvalidModelSource"));
                end

                resetGLUE2Portal(this,objH,'ShowTargetInContext');
                this.ResolvedSource=objH;
                this.SourceBounds=this.GLUE2Portal.getTargetBounds();
            else
                resetGLUE2Portal(this,[],'ShowTargetInContext');
                this.ResolvedSource=[];
                this.SourceBounds=[];
            end
            this.SpecifiedSource=source;
        end

        function source=get.Source(this)
            source=this.SpecifiedSource;
        end

        function bounds=getSourceBounds(this)





            bounds=this.SourceBounds;
        end
    end

    methods(Access=protected)
        function propGroup=getPropertyGroups(this)
            propList=struct(...
            "Source",this.Source,...
            "Theme",this.Theme,...
            "BackgroundColor",this.BackgroundColor,...
            "ShowBadges",this.ShowBadges,...
            "Format",this.Format,...
            "Filename",this.Filename,...
            "Scaling",this.Scaling);

            if(this.Scaling=="Zoom")
                propList.Zoom=this.Zoom;
                propList.MaxSize=this.MaxSize;
            else
                propList.Size=this.Size;
            end
            propGroup=matlab.mixin.util.PropertyGroup(propList);
        end

        function backgroundColor=getTargetBackgroundColor(this)
            target=this.ResolvedSource;
            if isa(target,"Stateflow.Object")
                if isprop(target,"Chart")
                    chart=target.Chart;
                else
                    chart=target;
                end
                backgroundColor=chart.ChartColor;

            else
                parent=get_param(target,"Parent");
                screenColor=get_param(parent,"ScreenColor");

                if(~isempty(regexp(screenColor,"\d+","once")))
                    backgroundColor=sscanf(screenColor,"[%f, %f, %f]")';
                else
                    namedColor=slreportgen.utils.internal.snapshot.SimulinkColor(screenColor);
                    backgroundColor=rgb(namedColor);
                end
            end

            backgroundColor=[backgroundColor,1];
        end

        function targetSceneRect=getSpecifiedTargetSceneRect(this)
            targetSceneRect=getSourceBounds(this);
        end
    end
end

