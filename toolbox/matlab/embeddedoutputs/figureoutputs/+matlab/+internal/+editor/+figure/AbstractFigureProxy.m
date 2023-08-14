classdef(Abstract)AbstractFigureProxy<handle






    properties
        FigureId;
        DeserializedFigure;
        Canvas;
        ServerID;
        Line;
        CachedFigureCreationListenerState;
    end

    methods(Abstract)
        createWebFigureSnapshot(this,fig)
    end

    methods(Access=protected)
        function suspendFigureCreationListeners(this)
            import matlab.internal.editor.*


            figureCreationListeners=EODataStore.getRootField(FigureManager.EDITOR_LISTEN_APP_DATA_TAG);
            if~isempty(figureCreationListeners)
                this.CachedFigureCreationListenerState=[figureCreationListeners.Enabled];
                for k=1:length(figureCreationListeners)
                    figureCreationListeners(k).Enabled=false;
                end
            end
        end

        function restoreFigureCreationListeners(this)
            import matlab.internal.editor.*

            figureCreationListeners=EODataStore.getRootField(FigureManager.EDITOR_LISTEN_APP_DATA_TAG);
            for k=1:length(figureCreationListeners)
                figureCreationListeners(k).Enabled=this.CachedFigureCreationListenerState(k);
            end
        end
    end

    methods
        function delete(this)
            if~isempty(this.DeserializedFigure)&&ishghandle(this.DeserializedFigure)
                try
                    if~matlab.internal.editor.FigureManager.useEmbeddedFigures
                        delete(this.DeserializedFigure);
                    end
                catch

                end
            end
        end
    end
end