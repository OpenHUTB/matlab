classdef DistributedFileMetadataDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods

        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.isMOTW
            import comparisons.internal.dispatcherutil.isTypeCompatible

            bool=~isMOTW()...
            &&isTypeCompatible(options.Type,obj.getType())...
            &&isDistributedFileMetadata(first.Path)...
            &&isDistributedFileMetadata(second.Path);
        end

        function app=handle(obj,first,second,options)
            options.Type=obj.getType();
            app=comparisons.internal.dispatcherutil.compareJava(first,second,options);
        end

        function priority=getPriority(~,~,~,~)
            priority=15;
        end

        function type=getType(~)
            type="ProjectMetadata";
        end


        function str=getDisplayType(~)
            str="Project definition files comparison";
        end
    end

end


function bool=isDistributedFileMetadata(file)
    import comparisons.internal.getXMLRootTagName
    import matlab.internal.project.comparisons.Utils
    bool=Utils.hasProjectMetaDataExtension(file)...
    &&Utils.hasTypeStructure(file)...
    &&Utils.hasType(file,"File")...
    &&strcmp(getXMLRootTagName(file),"Info");
end
