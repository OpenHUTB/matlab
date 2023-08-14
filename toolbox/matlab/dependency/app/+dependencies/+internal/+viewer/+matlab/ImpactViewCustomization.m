classdef ImpactViewCustomization<dependencies.internal.viewer.ViewCustomization




    methods
        function customize(~,controller,~)
            view=controller.View;
            view.ContextMenu.insertAt(i_createImpactMenuSection(view),2);
        end
    end

end


function section=i_createImpactMenuSection(view)
    import dependencies.internal.viewer.ImpactType;
    section=dependencies.internal.viewer.MenuSection(view.getViewModel);
    section.Items.add(i_createMenuItem(view,ImpactType.ALL_DEPENDENCIES,"AllDependenciesMenuItem"));
    section.Items.add(i_createMenuItem(view,ImpactType.IMPACTED,"ImpactedMenuItem"));
    section.Items.add(i_createMenuItem(view,ImpactType.REQUIRED,"RequiredMenuItem"));
end


function item=i_createMenuItem(view,type,resource)
    function show(controller,nodes)
        controller.filter(nodes,type);
    end

    item=dependencies.internal.viewer.MenuItem.createFor(view,@show);
    item.Name=string(message("MATLAB:dependency:viewer:"+resource));
    item.SelectionModel=...
    dependencies.internal.viewer.SelectionModel.REQUIRE_SELECTION;
end
