classdef EmbeddedUiFigureFigureProxy<matlab.internal.editor.figure.AbstractFigureProxy






    methods
        function this=EmbeddedUiFigureFigureProxy(figureId,line)
            this.FigureId=figureId;
            this.Line=line;
        end

        function createWebFigureSnapshot(this,fig)





            this.DeserializedFigure=fig;
            set(this.DeserializedFigure,'Internal',true,'Color',[1,1,1]);
            canvas=this.DeserializedFigure.getCanvas;
            canvas.ErrorCallback=[];
        end



        function figureStruct=showEmbeddedUIFigure(this,editorId)

            import matlab.internal.editor.*
            import matlab.internal.editor.figure.*

            pixpos=hgconvertunits(this.DeserializedFigure,this.DeserializedFigure.Position,...
            this.DeserializedFigure.Units,'pixels',this.DeserializedFigure.Parent);


            efPacket=matlab.ui.internal.FigureServices.getEmbeddedFigurePacket(this.DeserializedFigure);

            figureStruct=struct('figId',this.FigureId,'hFig',this.DeserializedFigure,...
            'isPending',false,'renderWarning','','lineNumbers',this.Line,...
            'figureSize',pixpos(3:end),'serverID',mls.internal.toJSON(efPacket),'snapshotTaken',false,'useEmbedded',1);


            FigureManager.safeSetAppData(this.DeserializedFigure,FigureManager.FIGURE_UID,editorId,efPacket.channel);


            figureStruct.figureImage=[];




            figureStruct.figureData=matlab.internal.editor.figure.FigureData;



            FigureManager.addFigureOutputsAndStream(editorId,figureStruct);
        end
    end
end