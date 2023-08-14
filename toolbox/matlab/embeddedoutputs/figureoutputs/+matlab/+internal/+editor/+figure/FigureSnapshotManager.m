classdef FigureSnapshotManager<handle






    properties
        ClientFigureDeletionSubscription;
    end

    properties(Constant)

        CHANNEL='/liveeditor/figuresnapshots';
    end

    methods(Static)




        function obj=getInstance(peekflag)
mlock
            persistent instance;
            if nargin==0
                peekflag=false;
            end

            if~peekflag&&isempty(instance)
                instance=matlab.internal.editor.figure.FigureSnapshotManager;
            end
            obj=instance;
        end




        function deleteFigureSnapshots(editorId,figureIds)
            matlab.internal.editor.figure.FigureSnapshotManager.getInstance.doDeleteFigureSnapshots(editorId,figureIds);
        end




        function handleDeleteMessage(msg)
            matlab.internal.editor.figure.FigureSnapshotManager.deleteFigureSnapshots(msg.editorId,eval(msg.figureIds));
        end

        function create
            matlab.internal.editor.figure.FigureSnapshotManager.getInstance;
        end
    end

    methods(Access=private)
        function this=FigureSnapshotManager
            this.ClientFigureDeletionSubscription=...
            message.subscribe(matlab.internal.editor.figure.FigureSnapshotManager.CHANNEL,...
            @(msg)matlab.internal.editor.figure.FigureSnapshotManager.handleDeleteMessage(msg),'enableDebugger',false);

        end
    end
    methods(Static,Access=private)

        function doDeleteFigureSnapshots(editorId,figureIds)
            import matlab.internal.editor.*

            allData=EODataStore.getEditorSubMap(editorId,FigureManager.EDITOR_STORE_APP_DATA_TAG);
            lineNumbers=allData.keys;
            for k=1:length(lineNumbers)
                figureData=allData(lineNumbers{k});
                figureIdsForLine=figureData.keys;
                for j=1:length(figureIdsForLine)
                    if any(strcmp(figureIdsForLine{j},figureIds))



                        figureProxy=figureData(figureIdsForLine{j});
                        delete(figureProxy)
                        remove(figureData,figureIdsForLine{j});
                    end
                end
            end
        end
    end

    methods
        function delete(this)
            message.unsubscribe(this.ClientFigureDeletionSubscription);
        end
    end
end