classdef AxesToolbarInteraction<...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.EnterExitInteraction




    properties
        ResponseData;
        ModeStrategy;
        ButtonInteractionsCreated=false;

        Toolbar;
    end


    properties
        strategy;
    end



    methods
        function obj=AxesToolbarInteraction(canvas,ax,toolbar)
            obj@matlab.graphics.interaction.graphicscontrol.InteractionObjects.EnterExitInteraction();


            obj.Type='AxesToolbarEnterExit';

            obj.Canvas=canvas;

            if~isa(ax,'matlab.graphics.axis.AbstractAxes')

                error(message('MATLAB:graphics:axestoolbar:InvalidParentAxes'));
            else
                obj.Object=ax;
            end

            obj.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Exit;

            obj.ModeStrategy=matlab.graphics.controls.internal.AxesBasedModeStrategy;

            obj.Toolbar=toolbar;

            tb=obj.getToolbar(obj.Object);

            if~isempty(tb)&&isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas')
                controlFactory=matlab.graphics.interaction.graphicscontrol.ControlFactory(canvas);
                controlFactory.createControl(tb);
                obj.ResponseData=getObjectID(tb);

                obj.setToolbarParent(tb);


                obj.setModeStrategyType(obj.Object);
                obj.ModeStrategy.CurrentToolbar=tb;
                obj.createListeners(obj.Object);


                obj.createButtonInteractions(tb);
            end
        end

        function response(obj,eventdata)
            obj.enterexitevent(eventdata)
        end


        function enterexitevent(obj,actionData)


            toolbar=obj.getToolbar(obj.Object);

            if~isempty(toolbar)&&isvalid(toolbar)
                switch(actionData.enterexit)
                case 'Entered'
                    obj.setToolbarParent(toolbar);



                    toolbar.setPosition(obj.Object);
                case 'Exited'
                end
            end
        end


        function parentSet=setToolbarParent(obj,toolbar)
            parentSet=false;

            if isempty(toolbar.NodeParent)
                toolbar.setTrueParent(toolbar.Parent);

                parentSet=true;
            else
                tbAncestor=ancestor(toolbar.NodeParent,'matlab.ui.internal.mixin.CanvasHostMixin');
                axesAncestor=ancestor(obj.Object,'matlab.ui.internal.mixin.CanvasHostMixin');

                if tbAncestor~=axesAncestor
                    toolbar.setTrueParent(toolbar.Parent);

                    parentSet=true;
                end
            end
        end





        function toolbar=getToolbar(obj,ax)
            try
                layout=ancestor(ax,'matlab.graphics.layout.Layout','node');

                toolbar=obj.Toolbar;

                if~isempty(layout)&&~isempty(layout.Toolbar)


                    if isa(ax,'matlab.graphics.axis.AbstractAxes')
                        toolbar=layout.Toolbar;
                        if isempty(toolbar)
                            toolbar=obj.Toolbar;
                        end
                    end
                else
                    if~any(isvalid(toolbar))&&strcmp(ax.ToolbarMode,'auto')
                        ax.Toolbar=matlab.graphics.controls.ToolbarController.getDefaultToolbar(ax);
                        toolbar=ax.Toolbar;
                        ax.ToolbarMode='auto';
                    end
                end


                if~isempty(toolbar)&&isvalid(toolbar)&&~isempty(ax)&&isvalid(ax)


                    if isempty(toolbar.NodeParent)||...
                        ancestor(toolbar.NodeParent,'matlab.ui.internal.mixin.CanvasHostMixin')~=...
                        ancestor(ax.Parent,'matlab.ui.internal.mixin.CanvasHostMixin')


                        if~isempty(toolbar)&&isvalid(toolbar)&&~isempty(toolbar.NodeParent)&&...
                            ~isempty(ax)&&isvalid(ax)&&strcmp(ax.ToolbarMode,'auto')
                            ax.Toolbar=[];
                            ax.ToolbarMode='auto';


                            toolbar=ax.Toolbar;
                        end


                        toolbar.Parent=[];

                        if~isa(ax,'matlab.graphics.axis.GeographicAxes')...
                            &&~isa(ax,'map.graphics.axis.MapAxes')...
                            &&~isa(ax,'matlab.graphics.axis.PolarAxes')
                            toolbar.Parent=ax;
                        else
                            toolbar.Axes=ax;
                            toolbar.parentToolbarToAxesPane(ax);
                        end
                    end
                end
            catch


                toolbar=[];
            end
        end


        function createButtonInteractions(obj,toolbar)

            if~obj.ButtonInteractionsCreated&&~isempty(toolbar)

                btns=toolbar.getToolbarButtons();

                for i=1:numel(btns)
                    btn=btns(i);
                    bi=matlab.graphics.controls.internal.AxesToolbarButtonInteraction(btn,obj.Canvas);
                    obj.Canvas.InteractionsManager.registerInteraction(btn,bi);
                end

                obj.ButtonInteractionsCreated=true;
            end
        end



        function createListeners(obj,ax)
            obj.ModeStrategy.createListeners(obj.Canvas,ax);
        end



        function setModeStrategyType(obj,ax)
            fig=ancestor(ax,'figure');


            if~isempty(fig)&&isprop(fig,'UseLegacyExplorationModes')&&fig.UseLegacyExplorationModes&&...
                isa(obj.ModeStrategy,'matlab.graphics.controls.internal.AxesBasedModeStrategy')
                obj.ModeStrategy=matlab.graphics.controls.internal.FigureBasedModeStrategy;
            end


            if obj.ModeStrategy.hasFigureChanged(fig)
                obj.ModeStrategy.resetListeners();
            end
        end



        function delete(obj)
            try

                if~isempty(obj.Toolbar)&&isvalid(obj.Toolbar)

                    btns=obj.Toolbar.getToolbarButtons();

                    for i=1:numel(btns)
                        btn=btns(i);
                        obj.Canvas.InteractionsManager.removeInteractionsOnObject(btn);
                    end
                end


                obj.Canvas.InteractionsManager.unregisterInteraction(obj);

            catch
            end
        end
    end
end
