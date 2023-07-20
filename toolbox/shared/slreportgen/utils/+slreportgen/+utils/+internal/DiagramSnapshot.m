classdef(Hidden)DiagramSnapshot<slreportgen.utils.internal.Snapshot










































    properties(Dependent)






        Source;
    end

    properties






        View(1,1)slreportgen.utils.internal.snapshot.View="Full";





        ViewRect(1,4)double{mustBeNumeric(ViewRect)}=[0,0,100,100];
    end

    properties(Access=protected)
        SpecifiedSource=[];
        ResolvedSource=[];
        SourceBounds=[];
    end

    methods
        function this=DiagramSnapshot(varargin)
            this=this@slreportgen.utils.internal.Snapshot(varargin{:});
        end

        function set.Source(this,source)
            if slreportgen.utils.hasDiagram(source)
                hid=slreportgen.utils.HierarchyService.getDiagramHID(source);
                diagH=slreportgen.utils.getSlSfHandle(hid);


                if strcmp(GLUE2.HierarchyService.getDomainName(hid),'Simulink')...
                    &&strcmp(get_param(diagH,'type'),'block_diagram')...
                    &&strcmp(get_param(diagH,'BlockDiagramType'),'library')
                    load_system(getfullname(diagH));
                end

                resetGLUE2Portal(this,diagH,'Default');
                this.ResolvedSource=diagH;
                this.SourceBounds=this.GLUE2Portal.getTargetBounds();
            else
                resetGLUE2Portal(this,[],'Default');
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
            if(this.Theme=="Modern")
                bounds=bounds+[-5,-5,10,10];
            end
        end

        function bounds=getSnapshotBounds(this,varargin)











            if isempty(this.Source)
                error(message("slreportgen:utils:Snapshot:SourceNotSpecified"));
            end

            target=this.ResolvedSource;
            if isempty(varargin)
                objH=target;
            else
                objH=slreportgen.utils.getSlSfHandle(varargin{1});
            end

            if(objH==target)
                sceneRect=getSourceBounds(this);
            else
                if isa(objH,"Stateflow.Object")
                    de=StateflowDI.SFDomain.id2DiagramElement(objH.Id);
                else
                    de=SLM3I.SLDomain.handle2DiagramElement(objH);
                end
                sceneRect=this.GLUE2Portal.getBounds(de);
            end
            bounds=sceneRectToOutputRect(this,sceneRect);


            if isempty(this.ImageFormatDPI)

                imgFormatDPI=getImageFormatDPI(this);
            else

                imgFormatDPI=this.ImageFormatDPI;
            end
            bounds=bounds*this.PortalDPI/imgFormatDPI;
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
            "Filename",this.Filename);

            propList.View=this.View;
            if(this.View=="Custom")
                propList.ViewRect=this.ViewRect;
            end

            propList.Scaling=this.Scaling;
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
                screenColor=get_param(target,"ScreenColor");
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
            switch this.View
            case "Full"
                targetSceneRect=getSourceBounds(this);

            case "Custom"
                targetSceneRect=this.ViewRect;

            case "Current"
                objH=this.ResolvedSource;
                if isa(objH,"Stateflow.Object")
                    view(objH);
                    editor=StateflowDI.SFDomain.getLastActiveEditorForChart(objH.Id);
                else
                    open_system(objH,"force");
                    name=getfullname(objH);
                    editor=GLUE2.Util.findAllEditors(name);
                end

                canvas=getCanvas(editor);
                targetSceneRect=canvas.SceneRectInView;
            end
        end
    end
end

