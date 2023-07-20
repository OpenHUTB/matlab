classdef DocumentView<handle




    properties(Constant)
        Name char=getString(message('evolutions:ui:Summary'));
    end

    properties(SetAccess=protected)
AppView
EvolutionTreeDocument
EvolutionDocument
    end

    methods
        function this=DocumentView(appView)
            this.AppView=appView;

            this.setDefaultContext;
            this.layoutDocument;
        end

        function v=getSubView(this,type)
            switch type
            case 'EvolutionDocument'
                v=this.EvolutionDocument;
            otherwise
                assert(strcmp(type,'EvolutionTreeDocument'));
                v=this.EvolutionTreeDocument;
            end
        end
    end

    methods
        function setDefaultContext(this)
            setManageContext(this);
        end

        function setManageContext(this)
            import evolutions.internal.app.document.*

            if~evolutions.internal.utils.checkHandle(this.EvolutionTreeDocument)
                this.EvolutionTreeDocument=EvolutionTreeWebDocument...
                .EvolutionTreeWebDocumentView(this);
            end
            if evolutions.internal.utils.checkHandle(this.EvolutionDocument)

                this.EvolutionDocument.close;
            end
        end

        function layoutDocument(this)

            if evolutions.internal.utils.checkHandle(this.EvolutionTreeDocument)
                addDocument(this.AppView,this.EvolutionTreeDocument);
            end

            if evolutions.internal.utils.checkHandle(this.EvolutionDocument)
                addDocument(this.AppView,this.EvolutionDocument);
            end
        end

        function docGroup=getDocGroup(this)
            docGroup=getDocGroup(this.AppView);
        end

        function docGroup=getWebDocGroup(this)
            docGroup=getWebDocGroup(this.AppView);
        end

        function delete(this)
            if~isempty(this.EvolutionTreeDocument)&&isvalid(this.EvolutionTreeDocument)
                delete(this.EvolutionTreeDocument)
            end
        end
    end

end
