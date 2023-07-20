classdef View<matlab.ui.container.internal.appcontainer.Panel




    properties(Constant)
        Name char=getString(message('evolutions:ui:MinimapTitle'));
        TagName char='minimap';
        FactoryPath="/js/MinimapPanelFactory";
    end

    methods
        function this=View(parent)
            appView=parent.AppView;
            this@matlab.ui.container.internal.appcontainer.Panel();
            this.Title=this.Name;
            this.Tag=this.TagName;
            this.Factory=appView.ModuleName+this.FactoryPath;
        end
    end
end


