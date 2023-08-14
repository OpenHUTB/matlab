classdef EmbeddedFigurePanel<matlab.ui.container.internal.appcontainer.Panel

    properties(SetAccess=private)
        Figure;
    end

    methods
        function this=EmbeddedFigurePanel(varargin)

            this=this@matlab.ui.container.internal.appcontainer.Panel(varargin{:});



            eFigure=matlab.ui.internal.embeddedfigure;
            efPacket=matlab.ui.internal.FigureServices.getEmbeddedFigurePacket(eFigure);


            this.Figure=eFigure;


            this.Factory="gbtclient/EmbeddedFigureFactory";


            efPacket.host='UIContainer';
            this.Content=efPacket;
        end

        function delete(obj)
            delete(obj.Figure);
        end

    end

end
