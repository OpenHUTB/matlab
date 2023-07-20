classdef UnifiedAxesInteractions<handle





    methods(Static)

        function createDefaultInteractions(ax,is2dim,numDataSpaces)



            import matlab.internal.editor.figure.*;



            fig=ancestor(ax,'figure');
            if matlab.graphics.interaction.internal.isPublishingTest()||...
                (~isempty(fig)&&(FigureUtils.isEditorEmbeddedFigure(fig)||...
                FigureUtils.isEditorSnapshotFigure(fig)))
                return;
            end




            canvas=matlab.graphics.interaction.internal.UnifiedAxesInteractions.getCanvas(ax);
            if isempty(canvas)||~isvalid(canvas)


                return
            end


            matlab.graphics.interaction.internal.UnifiedAxesInteractions.createInteractionsForTitlesAndLabels(ax);




            if strcmp(ax.InteractionContainer.Enabled,'off')&&strcmp(ax.InteractionContainer.EnabledMode,'manual')
                return;
            end

            if isprop(canvas,'CanvasReadyForInteraction')
                matlab.graphics.interaction.internal.UnifiedAxesInteractions.createDefaultInteractionsOnAxes(ax,is2dim,numDataSpaces);
            else
                matlab.graphics.interaction.internal.UnifiedAxesInteractions.queueCreateDefaultInteractionsOnAxes(canvas,ax);
            end

        end

        function queueCreateDefaultInteractionsOnAxes(javacanvas,ax)








            pendingAxes=matlab.graphics.interaction.internal.UnifiedAxesInteractions.queuedAxesOperations(javacanvas);
            if any(pendingAxes==ax)




                return
            end
            pendingAxes(end+1)=ax;
            matlab.graphics.interaction.internal.UnifiedAxesInteractions.queuedAxesOperations(javacanvas,pendingAxes);
        end

        function createDefaultInteractionsOnAxes(ax,is2dim,numDataSpaces)
            if isempty(ax)||~isvalid(ax)
                return;
            end





            ax.InteractionContainer.GObj=ax;
            ax.InteractionContainer.updateCanvasAndFigure();
            fig=ax.InteractionContainer.Figure;
            if isempty(fig)||~isvalid(fig)
                return;
            end


            EnabledAuto=strcmp(ax.InteractionContainer.EnabledMode,'auto');
            ToolbarOff=~matlab.ui.internal.isUIFigure(fig)&&...
            matlab.graphics.interaction.internal.UnifiedAxesInteractions.isFigureToolbarHidden(fig);


            ChartAncestor=~isempty(ancestor(ax,'matlab.graphics.chart.Chart'))...
            &&isempty(ancestor(ax,'matlab.graphics.chartcontainer.ChartContainer'));
            HWCallbacksExist=matlab.graphics.interaction.internal.UnifiedAxesInteractions.checkIfHWCallbacksExist(ax,fig);
            CameraPropertiesSet=matlab.graphics.interaction.internal.UnifiedAxesInteractions.checkIfCameraPropsSet(ax);



            if EnabledAuto
                if(ToolbarOff||ChartAncestor||CameraPropertiesSet)
                    ax.InteractionContainer.Enabled='off';
                elseif HWCallbacksExist
                    ax.InteractionContainer.Enabled_I='off';
                elseif~HWCallbacksExist
                    ax.InteractionContainer.Enabled_I='on';
                end
            end



            if~isprop(ax,'HardwareCallbackListener')
                matlab.graphics.interaction.internal.UnifiedAxesInteractions.createHardwareCallbackListeners(fig,ax);
            end



            if~isprop(ax,'ToolbarListeners')&&~ToolbarOff&&~matlab.ui.internal.isUIFigure(fig)
                matlab.graphics.interaction.internal.UnifiedAxesInteractions.createToolbarListeners(fig,ax);
            end

            ax.InteractionContainer.setupInteractions(is2dim,numDataSpaces);
        end

        function HWCallbacksExist=checkIfHWCallbacksExist(ax,fig)
            HWCallbacksExist=any(isvalid(ax))&&isvalid(fig)&&...
            (~isempty(fig.WindowButtonDownFcn)||...
            ~isempty(fig.WindowButtonMotionFcn)||...
            ~isempty(fig.WindowButtonUpFcn)||...
            ~isempty(fig.WindowScrollWheelFcn)||...
            ~isempty(ax.ButtonDownFcn)||...
            strcmp(ax.hasInteractionHint('HardwareCallbacks'),'on'));
        end

        function processQueuedDefaultInteractionInitialization(canvas)


            if isempty(canvas)||~isvalid(canvas)||...
                isempty(canvas.Parent)||~isvalid(canvas.Parent)||...
                ~isprop(canvas.Parent,'BeingDeleted')||strcmp(canvas.Parent.BeingDeleted,'on')
                return;
            end



            if~isprop(canvas,'CanvasReadyForInteraction')
                p=addprop(canvas,'CanvasReadyForInteraction');
                p.Transient=true;
                p.Hidden=true;
            end



            pendingAxes=matlab.graphics.interaction.internal.UnifiedAxesInteractions.queuedAxesOperations(canvas);
            pendingAxes(~isvalid(pendingAxes))=[];

            ax=gobjects(0);


            for i=1:length(pendingAxes)
                if isequal(canvas,ancestor(pendingAxes(i),'matlab.graphics.primitive.canvas.Canvas','node'))
                    ax(end+1)=pendingAxes(i);
                end
            end

            if isempty(ax)
                return
            end


            for k=1:length(ax)
                ax(k).InteractionContainer.updateInteractions();



                pendingAxes(pendingAxes==ax(k))=[];
            end


            matlab.graphics.interaction.internal.UnifiedAxesInteractions.queuedAxesOperations(canvas,pendingAxes);
        end

        function pendingAxes=queuedAxesOperations(javacanvas,updatedPendingAxes)



            if~isprop(javacanvas,'sQueuedAxesOperations')
                p=addprop(javacanvas,'sQueuedAxesOperations');
                p.Transient=true;
                p.Hidden=true;
                javacanvas.sQueuedAxesOperations=matlab.graphics.axis.Axes.empty;
            end

            if nargin>1
                javacanvas.sQueuedAxesOperations=updatedPendingAxes;
            end

            pendingAxes=javacanvas.sQueuedAxesOperations;
        end

        function can=getCanvas(ax)
            can=ancestor(ax,'matlab.graphics.primitive.canvas.Canvas','node');
            if~isempty(can)&&~isprop(can,'CanvasReadyForInteraction')&&isa(can,'matlab.graphics.primitive.canvas.HTMLCanvas')
                addprop(can,'CanvasReadyForInteraction');
            end
        end

        function ToolBarMenuBarPostSet(~,e,ax)
            fig=e.AffectedObject;
            if matlab.graphics.interaction.internal.UnifiedAxesInteractions.isFigureToolbarHidden(fig)
                ax.InteractionContainer.updateInteractions();
                ax.ToolbarListeners=[];
            end
        end

        function ret=isFigureToolbarHidden(fig)
            ret=(strcmp(fig.ToolBar,'none')&&strcmp(fig.ToolBarMode,'manual'))...
            ||((strcmp(fig.MenuBar,'none')&&strcmp(fig.MenuBarMode,'manual'))&&strcmp(fig.ToolBar,'auto'));
        end

        function ret=checkIfCameraPropsSet(ax)
            ret=isa(ax.ActiveDataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')&&...
            (strcmp(ax.CameraPositionMode,'manual')||...
            strcmp(ax.CameraTargetMode,'manual')||...
            strcmp(ax.CameraUpVectorMode,'manual')||...
            strcmp(ax.CameraViewAngleMode,'manual'));
        end

        function createToolbarListeners(fig,ax)
            p=addprop(ax,'ToolbarListeners');
            p.Transient=true;
            p.Hidden=true;
            ax.ToolbarListeners=event.proplistener.empty;


            ax.ToolbarListeners(1)=event.proplistener(fig,findprop(fig,'ToolBar'),'PostSet',@(o,e)matlab.graphics.interaction.internal.UnifiedAxesInteractions.ToolBarMenuBarPostSet(o,e,ax));
            ax.ToolbarListeners(2)=event.proplistener(fig,findprop(fig,'MenuBar'),'PostSet',@(o,e)matlab.graphics.interaction.internal.UnifiedAxesInteractions.ToolBarMenuBarPostSet(o,e,ax));
        end

        function createHardwareCallbackListeners(fig,ax)
            p=addprop(ax,'HardwareCallbackListener');
            p.Transient=true;
            p.Hidden=true;
            ax.HardwareCallbackListener=event.proplistener.empty;


            ax.HardwareCallbackListener(1)=event.proplistener(fig,findprop(fig,'WindowButtonDownFcn'),'PostSet',@(o,e)ax.InteractionContainer.updateInteractions());
            ax.HardwareCallbackListener(2)=event.proplistener(fig,findprop(fig,'WindowButtonMotionFcn'),'PostSet',@(o,e)ax.InteractionContainer.updateInteractions());
            ax.HardwareCallbackListener(3)=event.proplistener(fig,findprop(fig,'WindowButtonUpFcn'),'PostSet',@(o,e)ax.InteractionContainer.updateInteractions());
            ax.HardwareCallbackListener(4)=event.proplistener(fig,findprop(fig,'WindowScrollWheelFcn'),'PostSet',@(o,e)ax.InteractionContainer.updateInteractions());


            ax.HardwareCallbackListener(5)=event.proplistener(ax,findprop(ax,'ButtonDownFcn'),'PostSet',@(o,e)ax.InteractionContainer.updateInteractions());
        end

        function createInteractionsForTitlesAndLabels(ax)

            import matlab.graphics.interaction.internal.UnifiedAxesInteractions;

            if(isa(ax,'matlab.graphics.axis.Axes'))
                UnifiedAxesInteractions.createCartesianAxesTextInteractions(ax);
            elseif(isa(ax,'matlab.graphics.axis.GeographicAxes'))
                UnifiedAxesInteractions.createGeoAxesTextInteractions(ax);
            elseif(isa(ax,'matlab.graphics.axis.PolarAxes'))
                UnifiedAxesInteractions.createPolarAxesTextInteractions(ax);
            end

        end

        function createCartesianAxesTextInteractions(ax)


            import matlab.graphics.interaction.internal.UnifiedAxesInteractions;

            arr=[ax.Title_IS,ax.Subtitle_IS,...
            ax.XLabel_IS,ax.YLabel_IS,ax.ZLabel_IS];

            UnifiedAxesInteractions.setDefaultBehaviorForTextArray(arr);
        end

        function createGeoAxesTextInteractions(ax)


            import matlab.graphics.interaction.internal.UnifiedAxesInteractions;

            lat_axis=ax.LatitudeAxis_I;
            long_axis=ax.LongitudeAxis_I;
            arr=[ax.Title_IS,ax.Subtitle_IS,...
            lat_axis.Label_IS,long_axis.Label_IS];

            UnifiedAxesInteractions.setDefaultBehaviorForTextArray(arr);
        end

        function createPolarAxesTextInteractions(ax)


            import matlab.graphics.interaction.internal.UnifiedAxesInteractions;

            arr=[ax.Title_IS,ax.Subtitle_IS];

            UnifiedAxesInteractions.setDefaultBehaviorForTextArray(arr);
        end

        function setDefaultBehaviorForTextArray(arr)
            import matlab.graphics.interaction.internal.UnifiedAxesInteractions;

            for i=1:length(arr)
                t=arr(i);
                if(~isempty(t))
                    UnifiedAxesInteractions.setDefaultBehaviorForText(t);
                end
            end
        end


        function setDefaultBehaviorForText(t)













            if(isprop(t,'DefaultInteractionsValueHasBeenSet'))


                return;
            end

            if(isempty(t.String))







                return;
            end


            p=addprop(t,'DefaultInteractionsValueHasBeenSet');
            p.Transient=true;
            p.Hidden=true;


            t.DefaultInteractionsValueHasBeenSet=true;








            f=ancestor(t,'figure','node');

            if(isempty(f)||~isequal(f.HandleVisibility,'on'))
                return;
            end




            if(strcmp(t.InteractionsMode,'manual'))
                return;
            end






            t.Interactions_I=[editInteraction];

        end

    end
end
