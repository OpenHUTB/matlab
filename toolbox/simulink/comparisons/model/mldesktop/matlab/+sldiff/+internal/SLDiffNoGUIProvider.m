classdef SLDiffNoGUIProvider<comparisons.internal.DiffNoGUIProvider




    methods

        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.dispatcherutil.isTypeCompatible
            bool=isTypeCompatible(options.Type,[obj.getType(),"mdl"])...
            &&hasModelExtension(first.Path)...
            &&hasModelExtension(second.Path);
        end

        function out=handle(~,first,second,~)
            import comparisons.internal.util.process
            out=process(...
            @()comparisons.internal.api.compare(first.Path,second.Path)...
            );
        end

        function priority=getPriority(~,~,~,~)
            priority=15;
        end

        function type=getType(~)
            type="SLX";
        end

        function str=getDisplayType(~)
            str=message("simulink_comparisons:mldesktop:DisplayType").string();
        end

    end

end

function bool=hasModelExtension(file)
    [~,~,ext]=fileparts(file);
    bool=strcmpi(ext,".mdl")||strcmpi(ext,".slx");
end
