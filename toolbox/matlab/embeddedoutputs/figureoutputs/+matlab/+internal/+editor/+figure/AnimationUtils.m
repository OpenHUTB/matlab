classdef AnimationUtils<handle







    methods(Static)
        function startAnimation(hFig)








            import matlab.internal.editor.*
            import matlab.internal.editor.figure.*

            if~AnimationUtils.isEmbeddedLiveEditorFigure(hFig)
                return
            end




            if FigureManager.allowAnimation
                return
            end

            editorId=FigureManager.safeGetAppData(hFig,FigureUtils.EDITOR_ID_APP_DATA_TAG);








            newLineNumber=OutputUtilities.getLineNumberForExecutingFileFrame(dbstack,editorId);




            StreamOutputsSignal.stream();
            figUid=FigureManager.safeGetAppData(hFig,FigureManager.FIGURE_UID,editorId);



            figureProxy=AnimatedFigureProxy(figUid,newLineNumber);
            figureProxy.createWebFigureSnapshot(hFig);
            figureProxy.showAnimatedFigure(editorId);





            animationTimer=findobjinternal(hFig,'-class','matlab.graphics.function.AnimationTimer');
            if~isempty(animationTimer)
                animationTimer.Parent=figureProxy.DeserializedFigure;
            end



            FigureManager.safeSetAppData(hFig,FigureManager.PENDING_FIGURE_PROXY,figureProxy);
        end

        function stopAnimation(hFig)
            import matlab.internal.editor.*
            import matlab.internal.editor.figure.*

            if~AnimationUtils.isEmbeddedLiveEditorFigure(hFig)
                return
            end

            if FigureManager.allowAnimation
                return
            end




            figureProxy=FigureManager.safeGetAppData(hFig,FigureManager.PENDING_FIGURE_PROXY);
            set(figureProxy.DeserializedFigure.Children,'Parent',hFig);
            animationTimer=findobjinternal(figureProxy.DeserializedFigure,'-class','matlab.graphics.function.AnimationTimer');
            if~isempty(animationTimer)
                animationTimer.Parent=hFig;
            end
        end


        function status=isEmbeddedLiveEditorFigure(hFig)




            import matlab.internal.editor.figure.FigureUtils;
            import matlab.internal.editor.FigureManager;
            status=false;



            if strcmp(hFig.Visible,'on')||(strcmp(hFig.Visible,'off')&&...
                strcmp(hFig.VisibleMode,'manual'))
                return
            end

            if isempty(FigureManager.safeGetAppData(hFig,FigureUtils.EDITOR_ID_APP_DATA_TAG))
                return
            end

            status=true;

        end
    end
end