classdef AttributeViewCustomization<dependencies.internal.viewer.ViewCustomization




    methods

        function customize(~,controller,~)
            view=controller.View;
            registry=dependencies.internal.attribute.Registry.Instance;
            for analyzer=registry.AttributeAnalyzers'
                view.addAttributeAnalyzer(analyzer);
            end
        end

    end

end
