classdef DistributedLabelDataDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods

        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.isMOTW
            import comparisons.internal.dispatcherutil.isTypeCompatible

            bool=~isMOTW()...
            &&isTypeCompatible(options.Type,obj.getType())...
            &&isDistributedLabelData(first.Path)...
            &&isDistributedLabelData(second.Path);
        end

        function app=handle(obj,first,second,options)
            options.Type=obj.getType();
            app=comparisons.internal.dispatcherutil.compareJava(first,second,options);
        end

        function priority=getPriority(~,~,~,~)
            priority=15;
        end

        function type=getType(~)
            type="Label Data";
        end


        function str=getDisplayType(~)
            str="Project label data comparison";
        end
    end

end


function bool=isDistributedLabelData(file)
    import comparisons.internal.getXMLRootTagName
    import matlab.internal.project.comparisons.Utils
    bool=Utils.hasProjectMetaDataExtension(file)...
    &&Utils.hasTypeStructure(file)...
    &&Utils.hasType(file,"LabelData")...
    &&strcmp(getXMLRootTagName(file),"Info");
end