classdef EvolutionTreeWebDocumentView<evolutions.internal.ui.tools.ToolstripDocument





    properties(Constant)
        Name char=getString(message("evolutions:ui:EvolutionTreeSection"));
        TagName char='evolutionTreeWebDocument';
    end

    properties
AppView

EvolutionPlotView
Debug
    end

    methods
        function this=EvolutionTreeWebDocumentView(parent)
            parentDocGroup=getWebDocGroup(parent);
            configuration.DocumentGroupTag=parentDocGroup.Tag;
            configuration.Closable=0;
            this@evolutions.internal.ui.tools.ToolstripDocument(configuration);
            this.AppView=parent.AppView;
            this.Debug=parent.AppView.Debug;

            createDocumentComponents(this);
            layoutDocument(this);
        end

        function v=getSubView(this,type)

            assert(strcmp(type,'EvolutionPlotView'),'Invalid type');
            v=this.EvolutionPlotView;
        end
    end

    methods
        function createDocumentComponents(this)
            import evolutions.internal.app.document.*
            this.EvolutionPlotView=EvolutionTreeWebDocument.EvolutionWebPlotView(this);
        end

        function layoutDocument(this)

            layoutView(this.EvolutionPlotView);
        end

        function delete(this)
            if~isempty(this.EvolutionPlotView)&&isvalid(this.EvolutionPlotView)
                delete(this.EvolutionPlotView)
            end
        end
    end
end


