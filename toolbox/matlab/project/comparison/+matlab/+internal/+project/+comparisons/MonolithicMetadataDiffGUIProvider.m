classdef MonolithicMetadataDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods

        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.isMOTW
            import comparisons.internal.dispatcherutil.isTypeCompatible

            bool=~isMOTW()...
            &&isTypeCompatible(options.Type,obj.getType())...
            &&isMonolithicMetadata(first.Path)...
            &&isMonolithicMetadata(second.Path);
        end

        function app=handle(obj,first,second,options)
            options.Type=obj.getType();
            app=comparisons.internal.dispatcherutil.compareJava(first,second,options);
        end

        function priority=getPriority(~,~,~,~)
            priority=15;
        end

        function type=getType(~)
            type="Project Monolithic Metadata";
        end


        function str=getDisplayType(~)
            str="Project definition file comparison";
        end
    end

end


function bool=isMonolithicMetadata(file)
    import matlab.internal.project.comparisons.Utils
    bool=Utils.hasProjectMetaDataExtension(file)...
    &&isRootTagCorrect(file);
end

function bool=isRootTagCorrect(file)
    bool=false;

    tag=comparisons.internal.getXMLRootTag(file);
    if isempty(tag)
        return
    end

    if~strcmp(tag.Name,"project")
        return
    end

    for attr=tag.Attributes
        if strcmp(attr.Name,'MetadataType')&&strcmp(attr.Value,'monolithic')
            bool=true;
            return
        end
    end
end
