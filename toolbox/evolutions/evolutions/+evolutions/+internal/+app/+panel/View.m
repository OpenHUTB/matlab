classdef View<handle




    properties(Constant)
        Name char='App Panels';
    end

    properties(SetAccess=protected)
AppView

FileViewer
PropertyInspector
MiniMap
    end

    methods
        function this=View(appView)
            this.AppView=appView;

            this.setDefaultContext;
        end

        function v=getSubView(this,type)
            switch type
            case{'EvolutionInfo','EvolutionTreeInfo','PropertyInspector','FileList','FileInfo','EdgeInfo'}
                v=this.PropertyInspector;
            case 'Minimap'
                v=this.MiniMap;
            otherwise
                assert(strcmp(type,'FileViewer'));
                v=this.FileViewer;
            end
        end
    end

    methods
        function setDefaultContext(this)
            setManageContext(this);
        end

        function setManageContext(this)

            createAndAddPanel(this,'PropertyInspector');
            createAndAddPanel(this,'MiniMap');
            if(evolutions.internal.getFeatureState('EnableWebview'))
                createAndAddPanel(this,'FileViewer');
            end
        end

    end

    methods(Access=private)
        function createAndAddPanel(this,panelName)
            if~evolutions.internal.utils.checkHandle(this.(panelName))
                this.(panelName)=evolutions.internal.app.panel...
                .(panelName).View(this);
                addPanel(this.AppView,this.(panelName));
            else
                this.(panelName).Opened=1;
            end
        end

        function removeExistingPanel(this,panelName)
            this.(panelName).Opened=0;
        end
    end

end


