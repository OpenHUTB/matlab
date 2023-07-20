classdef DictDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods
        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.dispatcherutil.isTypeCompatible
            import comparisons.internal.isMOTW

            bool=isDictFile(first.Path)&&isDictFile(second.Path)&&...
            isTypeCompatible(options.Type,obj.getType())&&~isMOTW();
        end

        function app=handle(obj,first,second,options)
            if useNoJava()
                options=comparisons.internal.dispatcherutil.extractTwoWayOptions(options);
                app=comparisons.internal.dict.diff(first,second,options);
            else
                options.Type=obj.getType();
                app=comparisons.internal.dispatcherutil.compareJava(first,second,options);
            end
        end

        function priority=getPriority(~,~,~,~)
            priority=10;
        end

        function type=getType(~)
            type="DataDict";
        end


        function str=getDisplayType(~)
            str=message("comparisons:mldesktop:DisplayTypeExtension",...
            "(.sldd)").string();
        end
    end

end

function bool=useNoJava()
    bool=settings().comparisons.dict.UseNoJava.ActiveValue...
    ||settings().comparisons.NoJavaVisdiff.ActiveValue;
end

function flag=isDictFile(file)
    [~,~,ext]=fileparts(file);
    flag=strcmpi(ext,'.sldd');
end
