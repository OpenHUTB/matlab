classdef ProjectArchiveDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods

        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.isMOTW
            import comparisons.internal.dispatcherutil.isTypeCompatible

            bool=~isMOTW()...
            &&isTypeCompatible(options.Type,obj.getType())...
            &&isProjectArchive(first.Path)...
            &&isProjectArchive(second.Path);
        end

        function app=handle(obj,first,second,options)
            options.Type=obj.getType();
            app=comparisons.internal.dispatcherutil.compareJava(first,second,options);
        end

        function priority=getPriority(~,~,~,~)
            priority=15;
        end

        function type=getType(~)
            type="ProjectArchive";
        end


        function str=getDisplayType(~)
            str="Project Archive comparison";
        end
    end

end


function bool=isProjectArchive(file)
    [~,~,ext]=fileparts(file);
    if~strcmpi(ext,".mlproj")
        bool=false;
        return
    end

    coreProperties=comparisons.internal.getCoreProperties(file);
    if isempty(coreProperties)
        bool=false;
        return
    end

    bool=strcmp(coreProperties.ContentType,'application/vnd.mathworks.project.archive')&&...
    strcmp(coreProperties.Category,'Project');
end
