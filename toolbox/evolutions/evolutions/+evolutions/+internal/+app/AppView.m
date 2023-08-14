classdef AppView<evolutions.internal.ui.tools.ToolstripApp















    properties(Constant)
        Title=getString(message('evolutions:ui:AppTitle'));
        Name='DesignEvolutions';
        AppIconPath=fullfile(matlabroot,'toolbox','evolutions',...
        'evolutions','+evolutions','+internal','resources','icons','create_32.png');
    end

    properties(SetAccess=protected)
EventHandler

ToolstripView
DocumentView
CostReportView
WebView
PanelView
    end

    properties(Access=protected)
DocumentDestroyedListener
    end

    methods
        function this=AppView(appController)

            this@evolutions.internal.ui.tools.ToolstripApp(appController.Debug);
            this.EventHandler=appController.EventHandler;
        end

        function v=getSubView(this,type)
            switch type
            case{'ProjectSection','EvolutionTreeSection','FileSection',...
                'WorkingModelSection','EvolutionsSection',...
                'CompareModeSection','ManageTabGroup','EvolutionsTab',...
                'CompareSection','CloseCompareSection','CompareTabGroup',...
                "ManageTreeViewSection","CompareTreeViewSection",...
                'ReportSection','ProfileSection','EnvironmentSection'}
                v=getSubView(this.ToolstripView,type);
            case 'PanelView'
                v=this.PanelView;
            case{'FileList','EvolutionTreeInfo','EvolutionInfo',...
                'PropertyInspector','FileInfo','Minimap','FileViewer'}
                v=getSubView(this.PanelView,type);
            case 'DocumentView'
                v=this.DocumentView;
            case 'CostView'
                v=this.CostReportView;
            otherwise
                v=getSubView(this.DocumentView,type);
            end
        end



        function setDefaultLayout(this,layout)
            this.ToolGroup.DefaultLayout=layout;
        end

        function setLayout(this,layout)
            this.ToolGroup.Layout=layout;
        end

    end

    methods(Access=protected)

        function createAppComponents(this)
            this.ToolstripView=evolutions.internal.app.toolstrip...
            .ToolstripView(this);


            this.DocumentView=evolutions.internal.app.document.DocumentView(this);


            this.PanelView=evolutions.internal.app.panel.View(this);
        end

        function closeAllFigures(this)
            if~isempty(this.DocumentView)&&isvalid(this.DocumentView)
                delete(this.DocumentView)
            end

            if~isempty(this.PanelView)&&isvalid(this.PanelView)
                delete(this.PanelView)
            end
        end

    end

end


