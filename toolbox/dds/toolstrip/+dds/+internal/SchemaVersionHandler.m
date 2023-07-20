classdef SchemaVersionHandler<handle




    properties(Constant,GetAccess=private)
        singleton=dds.internal.SchemaVersionHandler();
    end

    properties(GetAccess=private,SetAccess=private)
        schemaVersion;
    end

    methods(Static,Access=public)



        function inst=instance()
            inst=dds.internal.SchemaVersionHandler.singleton;
        end

        function enable=isCompatible(uVer)

            assert(ischar(uVer)||isStringScalar(uVer)||isnumeric(uVer));
            if ischar(uVer)||isStringScalar(uVer)
                uVer=str2double(uVer);
            end
            verStr=dds.internal.SchemaVersionHandler.instance().getSchemaVersion();
            ver=str2double(verStr);
            enable=ver>=uVer;
        end
    end

    methods(Access=private)



        function this=SchemaVersionHandler()
            this.schemaVersion=[];
        end
    end

    methods(Access=public)


        function setSchemaVersion(this,schemaVersion)
            this.schemaVersion=schemaVersion;
        end

        function schemaVersion=getSchemaVersion(this)
            assert(~isempty(this.schemaVersion),'Schema version has not been set in SchemaVersionHandler');
            schemaVersion=this.schemaVersion;
        end

    end

end
