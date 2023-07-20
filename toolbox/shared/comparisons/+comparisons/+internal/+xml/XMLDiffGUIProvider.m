classdef XMLDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods
        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.isMOTW
            import comparisons.internal.dispatcherutil.isTypeCompatible

            bool=~isMOTW()&&isTypeCompatible(options.Type,obj.getType())&&...
            isXML(first.Path)&&isXML(second.Path);
        end

        function app=handle(obj,first,second,options)
            options.Type=obj.getType();
            app=comparisons.internal.dispatcherutil.compareJava(first,second,options);
        end

        function priority=getPriority(~,~,~,~)
            priority=5;
        end

        function type=getType(~)
            type="XML";
        end

        function str=getDisplayType(~)
            str=message("comparisons:comparisons:XMLDisplayType").string();
        end
    end

end

function bool=isXML(path)
    bool=~isempty(comparisons.internal.getXMLRootTagName(path));
end
