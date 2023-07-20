classdef GraphmlDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods

        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.dispatcherutil.isTypeCompatible

            bool=isTypeCompatible(options.Type,obj.getType())...
            &&isGraph(first.Path)...
            &&isGraph(second.Path);
        end

        function app=handle(~,first,second,options)
            options=comparisons.internal.dispatcherutil.extractTwoWayOptions(options);
            app=dependencies.internal.graph.diff(first,second,options);
        end

        function priority=getPriority(~,~,~,~)
            priority=15;
        end

        function type=getType(~)
            type="GraphML";
        end


        function str=getDisplayType(~)
            str=string(message("MATLAB:dependency:comparisons:GUIProviderDisplayType"));
        end
    end

end

function bool=isGraph(file)
    graphExtensions=dependencies.internal.Registry.Instance.getGraphReaderExtensions;
    [~,~,ext]=fileparts(file);
    bool=any(strcmpi(ext,graphExtensions))&&isGraphReadable(file);
end

function bool=isGraphReadable(file)
    try
        dependencies.internal.graph.read(file);
        bool=true;
    catch
        bool=false;
    end
end