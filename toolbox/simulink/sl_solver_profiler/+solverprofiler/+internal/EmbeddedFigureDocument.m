classdef EmbeddedFigureDocument<matlab.ui.container.internal.appcontainer.Document

    properties(SetAccess=private)
        Figure;
    end

    methods
        function this=EmbeddedFigureDocument(varargin)

            this=this@matlab.ui.container.internal.appcontainer.Document(varargin{:});



            eFigure=matlab.ui.internal.embeddedfigure;
            efPacket=matlab.ui.internal.FigureServices.getEmbeddedFigurePacket(eFigure);


            this.Figure=eFigure;


            efPacket.host='UIContainer';
            this.Content=efPacket;
        end

        function delete(obj)
            delete(obj.Figure);
        end

    end
end
