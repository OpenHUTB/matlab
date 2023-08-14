classdef EmbeddedFigureDocumentGroup<matlab.ui.container.internal.appcontainer.DocumentGroup

    methods

        function this=EmbeddedFigureDocumentGroup(varargin)

            this=this@matlab.ui.container.internal.appcontainer.DocumentGroup(varargin{:});


            this.DocumentFactory="gbtclient/EmbeddedFigureFactory";




            if this.Title==""
                this.Title="Figures";
            end

        end

    end
end
