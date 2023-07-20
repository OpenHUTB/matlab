classdef SchemaDefinitionResolver<matlab.io.xml.dom.EntityResolver





    properties(GetAccess=private,SetAccess=immutable)
        NamespaceSchema;
        VersionSchema;
    end

    methods(Access=public)

        function this=SchemaDefinitionResolver(namespaceSchema,versionSchema)
            narginchk(2,2)
            this.NamespaceSchema=namespaceSchema;
            this.VersionSchema=versionSchema;
        end

        function res=resolveEntity(this,ri)
            import matlab.io.xml.dom.ResourceIdentifierType
            riType=getResourceIdentifierType(ri);
            switch riType
            case ResourceIdentifierType.SchemaGrammar
                res=string(this.VersionSchema);
            case ResourceIdentifierType.SchemaImport
                res=string(this.NamespaceSchema);
            otherwise
                assert(false,...
                sprintf('Cannot resolve error type %s',riType));
            end
        end
    end
end


