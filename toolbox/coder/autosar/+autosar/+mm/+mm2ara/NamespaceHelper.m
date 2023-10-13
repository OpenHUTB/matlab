classdef NamespaceHelper < handle

    methods ( Static, Access = public )

        function writeBegNamespaces( codeWriter, nsCellArray )
            for ii = 1:numel( nsCellArray )
                codeWriter.wBlockStart( [ 'namespace ', nsCellArray{ ii } ] );
            end
        end

        function writeEndNamespaces( codeWriter, nsCellArray )
            for kk = numel( nsCellArray ): - 1:1
                codeWriter.wBlockEnd( [ 'namespace ', nsCellArray{ kk } ] );
            end
        end

        function qualifiedTypeName = getQualifiedTypeName( m3iType )
            assert( isa( m3iType, 'Simulink.metamodel.foundation.ValueType' ),  ...
                'Expected type as input' );
            qualifiedTypeName = m3iType.Name;
            if slfeature( 'AdaptiveAutosarNamespacesOnTypes' )

                namespaceStr = autosar.mm.mm2ara.NamespaceHelper.getNamespacesFor(  ...
                    m3iType, namespaceSeparator = '::' );
                qualifiedTypeName = [ namespaceStr, qualifiedTypeName ];
            end
        end

        function [ nsStr, nsCellArray ] = getNamespacesFor( m3iObj, namedArgs )



            arguments
                m3iObj( 1, 1 ){ mustBeA( m3iObj,  ...
                    [ "Simulink.metamodel.foundation.ValueType",  ...
                    "Simulink.metamodel.arplatform.interface.ServiceInterface" ] ) };
                namedArgs.namespaceSeparator ...
                    { mustBeA( namedArgs.namespaceSeparator, 'char' ),  ...
                    mustBeMember( namedArgs.namespaceSeparator, { '/', '::' } ) } = '::';
            end
            nsStr = '';
            nsCellArray = {  };

            if isa( m3iObj, 'Simulink.metamodel.foundation.ValueType' ) &&  ...
                    ~slfeature( 'AdaptiveAutosarNamespacesOnTypes' )

                return ;
            end

            if m3iObj.Namespaces.size(  ) > 0
                nsCellArray = cell( 0, m3iObj.Namespaces.size );
                for ii = 1:m3iObj.Namespaces.size
                    nsCellArray{ ii } = lower( m3iObj.Namespaces.at( ii ).Symbol );
                end
                nsStr = strjoin( nsCellArray, namedArgs.namespaceSeparator );
                nsStr = [ nsStr, namedArgs.namespaceSeparator ];
            end
        end
    end
end



