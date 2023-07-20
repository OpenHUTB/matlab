classdef SLDiffGUIProvider<comparisons.internal.DiffGUIProvider




    methods
        function bool=canHandle(obj,first,second,options)
            import comparisons.internal.dispatcherutil.isTypeCompatible
            import sldiff.internal.isModel
            bool=isTypeCompatible(options.Type,[obj.getType(),"mdl"])...
            &&isModel(first.Path)...
            &&isModel(second.Path);
        end

        function app=handle(obj,first,second,options)
            import comparisons.internal.dispatcherutil.sanitizeFiles
            [first,second,options]=sanitizeFiles(first,second,options,@sanitizeImpl);

            import comparisons.internal.isMOTW
            if isMOTW()||useNoJava()
                opts=comparisons.internal.dispatcherutil.extractTwoWayOptions(options);
                app=sldiff.internal.diff(first,second,opts);
            else
                if options.Type==""
                    options.Type=obj.getType();
                end
                app=comparisons.internal.dispatcherutil.compareJava(first,second,options);
            end
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

function bool=useNoJava()
    bool=settings().comparisons.NoJavaVisdiff.ActiveValue;
end

function source=sanitizeImpl(source)
    import sldiff.internal.getModelExt
    source=comparisons.internal.fileutil.sanitize(...
    source,NeedsValidName=true,TargetExt=getModelExt(source.Path));
end
