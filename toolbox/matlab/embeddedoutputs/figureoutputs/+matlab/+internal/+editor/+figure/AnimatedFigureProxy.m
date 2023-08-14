classdef AnimatedFigureProxy<matlab.internal.editor.figure.AbstractFigureProxy








    methods
        function this=AnimatedFigureProxy(figureId,line)
            this.FigureId=figureId;
            this.Line=line;
        end

        function createWebFigureSnapshot(this,fig)





            import matlab.internal.editor.*
            import matlab.internal.editor.figure.*




            this.suspendFigureCreationListeners;
            cleanupFcn=onCleanup(@()this.restoreFigureCreationListeners);

            figureEventDisabler=FigureEventDisabler;%#ok<NASGU>


            this.DeserializedFigure=matlab.ui.internal.embeddedfigure;
            set(this.DeserializedFigure,'Internal',false,'HandleVisibility','off',...
            'AutoResizeChildren','off','Color',[1,1,1]);
            canvas=this.DeserializedFigure.getCanvas;
            canvas.ServerSideRendering='on';
            canvas.ErrorCallback=[];



            set(fig.Children,'Parent',this.DeserializedFigure);

        end

        function showAnimatedFigure(this,editorId)




            import matlab.internal.editor.*
            import matlab.internal.editor.figure.*

            figureEventDisabler=FigureEventDisabler;%#ok<NASGU>

            pixpos=hgconvertunits(this.DeserializedFigure,this.DeserializedFigure.Position,...
            this.DeserializedFigure.Units,'pixels',this.DeserializedFigure.Parent);
            figureStruct=struct('figId',this.FigureId,'hFig',this.DeserializedFigure,...
            'isPending',true,'renderWarning','','lineNumbers',this.Line,...
            'figureSize',pixpos(3:end),'serverID',this.DeserializedFigure.getCanvas.ServerID);







            FigureManager.safeSetAppData(this.DeserializedFigure,FigureManager.FIGURE_UID,editorId,this.FigureId);




            figureStruct.figureImage=[];




            figureStruct.figureData=matlab.internal.editor.figure.FigureData;



            eventData=matlab.internal.editor.events.FigureReadyEventData(figureStruct,editorId);
            notify(matlab.internal.editor.FigureManager.getInstance,'FigureOutputReady',eventData);
            StreamOutputsSignal.forceStream();
        end

    end
end