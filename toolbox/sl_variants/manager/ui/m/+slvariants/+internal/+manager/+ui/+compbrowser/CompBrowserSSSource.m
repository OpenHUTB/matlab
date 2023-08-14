classdef CompBrowserSSSource<handle





    properties


        Children(1,:)slvariants.internal.manager.ui.compbrowser.CompBrowserSSRow;


        HierViewSource sl_variants.manager.view.HierarchyViewSource;



        ConfigDialogSchema(1,1)slvariants.internal.manager.ui.config.ConfigurationsDialogSchema;

        CurrentCompRow slvariants.internal.manager.ui.compbrowser.CompBrowserSSRow;

        CompConfigMap containers.Map;
    end

    methods
        function obj=CompBrowserSSSource(configSchema)
            if nargin==0
                return;
            end
            obj.ConfigDialogSchema=configSchema;
            obj.HierViewSource=slvariants.internal.manager.core.getViewSource(get_param(configSchema.BDName,'Handle'));
            obj.CompConfigMap=containers.Map;
        end

        function children=getChildren(obj,~,~)
            if~isempty(obj.Children)
                children=obj.Children;
                return;
            end
            children=slvariants.internal.manager.ui.compbrowser.CompBrowserSSRow(obj.HierViewSource.RootRow,obj);
            obj.Children=children;
        end

        function children=getAllRows(obj)
            children=[];
            for compRow=[obj.Children]
                children=[children,obj.getAllChildRows(compRow)];%#ok
            end
        end
    end

    methods
        function children=getAllChildRows(obj,compRow)
            if isempty(compRow.Children)
                children=compRow;
                return;
            end
            children=[];
            for childCompRow=[compRow.Children]
                childCompRow.getChildren();
                compRows=getAllChildRows(obj,childCompRow);
                children=[children,compRows];%#ok
            end
            children=[compRow,children];
        end
    end

    methods(Static,Hidden)

        function resetCompBrowserSource(dlg)
            configSchema=dlg.getSource();
            compBrowserSSSrc=configSchema.CompBrowserSSSrc;
            if isempty(compBrowserSSSrc)
                return;
            end
            compBrowserSSSrc.Children=slvariants.internal.manager.ui.compbrowser.CompBrowserSSRow.empty;
            slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.updateCompBrowser(configSchema.BDName);
        end
    end

end
