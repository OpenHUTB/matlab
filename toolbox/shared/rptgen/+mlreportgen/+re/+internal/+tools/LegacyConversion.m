classdef(Hidden)LegacyConversion<handle




    properties(Access=private)
Map
    end

    methods(Static)
        function this=instance()
            persistent INSTANCE

            if isempty(INSTANCE)
                INSTANCE=mlreportgen.re.internal.tools.LegacyConversion();
            end
            this=INSTANCE;
        end

        function put(v1,v2)

            this=mlreportgen.re.internal.tools.LegacyConversion.instance();
            if~this.isInitialized()
                this.Map=containers.Map();
            end
            this.Map(v1)=v2;
        end

        function v2=get(v1)


            this=mlreportgen.re.internal.tools.LegacyConversion.instance();
            if isKey(this.Map,v1)
                v2=this.Map(v1);
            else
                v2=string.empty();
            end
        end

        function tf=isInitialized()


            this=mlreportgen.re.internal.tools.LegacyConversion.instance();
            tf=isa(this.Map,"containers.Map");
        end
    end

    methods(Access=private)
        function this=LegacyConversion
        end
    end
end