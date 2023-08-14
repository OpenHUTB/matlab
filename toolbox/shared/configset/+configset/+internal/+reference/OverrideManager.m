classdef OverrideManager<handle






    properties
ConfigSet
    end

    methods
        function obj=OverrideManager(in)









            if isa(in,'Simulink.ConfigSetRoot')
                cs=in;
            else




                try
                    cs=getActiveConfigSet(in);
                    original=get_param(in,'OriginalConfigSetName');
                    if~isempty(original)
                        cs=getConfigSet(in,original);
                    end
                catch me
                    throwAsCaller(me);
                end
            end
            obj.ConfigSet=cs;
        end

        function override(obj,param,value)


            if~obj.isConfigSetRef

                error(message('configset:util:OverrideNonConfigSetRef',param));
            end

            ref=obj.ConfigSet;
            overridden=ref.isParameterOverridden(param);


            ref.enableOverride(param);


            if nargin>=3
                try
                    set_param(ref,param,value);
                catch me
                    if~overridden

                        ref.restore(param);
                    end
                    rethrow(me);
                end
            end
        end

        function out=getParameterOverrides(obj)




            out=string.empty;
            if obj.isConfigSetRef
                overrides=get_param(obj.ConfigSet,'ParameterOverrides');
                if~isempty(overrides)
                    out=convertCharsToStrings(overrides);
                end
            end
        end

        function out=isParameterOverridden(obj,param)

            out=false;
            if obj.isConfigSetRef
                out=obj.ConfigSet.isParameterOverridden(param);
            end
        end

        function restoreAll(obj)

            if obj.isConfigSetRef
                obj.ConfigSet.restoreAll;
            end
        end

        function restore(obj,param)

            if obj.isConfigSetRef
                obj.ConfigSet.restore(param);
            else

                get_param(obj.ConfigSet,param);
            end
        end
    end

    methods(Access=private)
        function out=isConfigSetRef(obj)
            out=isa(obj.ConfigSet,'Simulink.ConfigSetRef');
        end
    end
end
