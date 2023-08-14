


classdef AxesController<handle

    properties

Application

    end

    properties(Access=private)
Graphs
LoadingPanel
LoadingText

CurrentGraph
    end

    methods
        function obj=AxesController(App,panel)
            obj.Application=App;




            obj.Graphs{1,1}=phased.apps.internal.SensorArrayViewer.ArrayGraphGeometry(App,panel,'Geometry');

            for i=1:length(enumeration('phased.apps.internal.SensorArrayViewer.ArrayDir2dOps'))
                obj.Graphs{2,i}=phased.apps.internal.SensorArrayViewer.ArrayGraph2D(...
                App,...
                panel,...
                phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.getOpAtPosition(i));
            end

            for i=1:length(enumeration('phased.apps.internal.SensorArrayViewer.ArrayDir3dOps'))
                obj.Graphs{3,i}=phased.apps.internal.SensorArrayViewer.ArrayGraph3D(...
                App,...
                panel,...
                phased.apps.internal.SensorArrayViewer.ArrayDir3dOps.getOpAtPosition(i));
            end

            obj.Graphs{4,1}=phased.apps.internal.SensorArrayViewer.ArrayGraphGratingLobe(App,panel,'GratingLobe');

            obj.setCurrentGraph();


            obj.LoadingPanel=uipanel(panel,...
            'Position',[0.02,0.03,0.96,0.97],...
            'Visible','off',...
            'Tag','LoadingPanelTag');

            obj.LoadingText=uicontrol('Parent',obj.LoadingPanel,'Style',...
            'text','Visible','on','HorizontalAlignment',...
            'center','String','Calculating Response',...
            'BackgroundColor',obj.Application.FigureHandle.Color,...
            'FontUnits','pixels','FontSize',20,'Units','Normalized','Position',[.25,.5,.5,.05],...
            'ForegroundColor',[0.2,0.2,0.2],'Tag','LoadingTextTag');
        end

        function render(obj)



            if obj.CurrentGraph.NeedsRedraw&&~isa(obj.CurrentGraph,'phased.apps.internal.SensorArrayViewer.ArrayGraphGeometry')
                obj.LoadingPanel.Visible='on';
                set(obj.LoadingText,'FontSize',min([obj.LoadingPanel.Parent.Position(3:4)./[25,36],20]));
                drawnow('expose');
            end
            set(obj.Application.FigureHandle,'HandleVisibility','on');
            obj.CurrentGraph.show();
            set(obj.Application.FigureHandle,'HandleVisibility','off');
            drawnow('expose');
            obj.LoadingPanel.Visible='off';

        end

        function setCurrentGraph(obj)

            vt=obj.Application.Visualization.ViewTypeIndex;
            op2DIndex=obj.Application.Visualization.AD2DDropNameIndex;
            op3DIndex=obj.Application.Visualization.AD3DDropNameIndex;

            inds=[1,1];
            inds(1)=vt;
            if vt==phased.apps.internal.SensorArrayViewer.ViewType.ArrayDirectivity2D.ID
                inds(2)=op2DIndex;
            elseif vt==phased.apps.internal.SensorArrayViewer.ViewType.ArrayDirectivity3D.ID
                inds(2)=op3DIndex;
            else
                inds(2)=1;
            end

            obj.CurrentGraph=obj.Graphs{inds(1),inds(2)};
        end

        function switchGraph(obj)

            obj.CurrentGraph.hide();
            obj.setCurrentGraph();
            obj.render();
        end

        function prepareRedraw(obj)
            for i=1:numel(obj.Graphs)
                if~isempty(obj.Graphs{i})
                    obj.Graphs{i}.NeedsRedraw=true;
                end
            end
        end

        function reset(obj)
            for i=1:numel(obj.Graphs)
                if~isempty(obj.Graphs{i})
                    obj.Graphs{i}.reset();
                end
            end
        end

        function setRotate(obj,onOff)
            obj.CurrentGraph.setRotate(onOff);
        end

        function setPan(obj,onOff)
            obj.CurrentGraph.setPan(onOff);
        end

        function[canPan,canRotate]=getToolbarOptions(obj)
            canPan=obj.CurrentGraph.CanPan;
            canRotate=obj.CurrentGraph.CanRotate;
        end

        function genCode(obj,mcode)
            mcode.addcr('%Create figure, panel, and axes');
            mcode.addcr('fig = figure;');
            mcode.addcr('panel = uipanel(''Parent'',fig);');
            mcode.addcr('hAxes = axes(''Parent'',panel,''Color'',''none'');');
            obj.CurrentGraph.genCode(mcode);
        end
    end

    methods



        function azCutValueChanged(obj,~,~)
            i1=phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.AzimuthCutLine.ID;
            i2=phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.AzimuthCutPolar.ID;
            obj.Graphs{2,i1}.NeedsRedraw=true;
            obj.Graphs{2,i2}.NeedsRedraw=true;

            obj.render();
        end

        function elCutValueChanged(obj,~,~)
            i1=phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.ElevationCutLine.ID;
            i2=phased.apps.internal.SensorArrayViewer.ArrayDir2dOps.ElevationCutPolar.ID;
            obj.Graphs{2,i1}.NeedsRedraw=true;
            obj.Graphs{2,i2}.NeedsRedraw=true;

            obj.render();
        end

        function showGeometryChanged(obj,~,~)
            obj.render();
        end

        function geometryOptionChanged(obj,~,~)

            obj.CurrentGraph.NeedsRedraw=true;
            obj.render();
        end
    end

end

