classdef ProjectTemplateDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods
        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.isMOTW
            import comparisons.internal.dispatcherutil.isTypeCompatible
            bool=~isMOTW()&&isTypeCompatible(options.Type,obj.getType())...
            &&isProjectTemplate(first.Path)...
            &&isProjectTemplate(second.Path);
        end

        function app=handle(obj,first,second,options)
            options.Type=obj.getType();
            app=comparisons.internal.dispatcherutil.compareJava(first,second,options);
        end

        function priority=getPriority(~,~,~,~)
            priority=15;
        end

        function type=getType(~)
            type="SimulinkProjectTemplate";
        end


        function str=getDisplayType(~)
            str="Simulink project template comparison";
        end
    end

end


function bool=isProjectTemplate(file)
    [~,~,ext]=fileparts(file);
    if~strcmpi(ext,".sltx")
        bool=false;
        return
    end

    coreProperties=comparisons.internal.getCoreProperties(file);
    if isempty(coreProperties)
        bool=false;
        return
    end

    bool=strcmp(coreProperties.ContentType,'application/vnd.mathworks.simulink.template')&&...
    strcmp(coreProperties.Category,'Project');
end
