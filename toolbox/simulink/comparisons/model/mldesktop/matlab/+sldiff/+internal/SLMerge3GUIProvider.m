classdef SLMerge3GUIProvider<comparisons.internal.Merge3GUIProvider




    methods
        function bool=canHandle(obj,theirs,base,mine,options)
            import comparisons.internal.dispatcherutil.isTypeCompatible
            import comparisons.internal.isMOTW
            import sldiff.internal.isModel
            bool=~isMOTW()...
            &&isTypeCompatible(options.Type,[obj.getType(),"mdl"])...
            &&isModel(base.Path)...
            &&isModel(mine.Path)...
            &&isModel(theirs.Path);
        end

        function app=handle(obj,theirs,base,mine,options)
            theirs=sanitize(theirs);
            base=sanitize(base);
            mine=sanitize(mine);

            import comparisons.internal.dispatcherutil.extractThreeWayOptions;
            if useNoJava()
                opts=extractThreeWayOptions(options);
                app=sldiff.internal.merge(theirs,base,mine,opts);
            else
                if options.Type==""
                    options.Type=obj.getType();
                end
                app=comparisons.internal.dispatcherutil.mergeThreeInJava(theirs,base,mine,options);
            end
        end

        function priority=getPriority(~,~,~,~,~)
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

function source=sanitize(source)
    import sldiff.internal.getModelExt
    source=comparisons.internal.fileutil.sanitize(...
    source,NeedsValidName=true,TargetExt=getModelExt(source.Path));
end

function bool=useNoJava()
    bool=settings().comparisons.NoJavaVisdiff.ActiveValue;
end
