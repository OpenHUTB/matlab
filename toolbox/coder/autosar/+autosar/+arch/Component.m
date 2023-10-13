classdef ( Hidden, Sealed )Component < autosar.arch.ComponentBase & matlab.mixin.CustomDisplay

    properties ( Dependent = true, SetAccess = private )
        ReferenceName
    end

    properties ( Dependent = true )
        Kind
    end

    methods ( Hidden, Access = protected )
        function propgrp = getPropertyGroups( ~ )

            proplist = { 'Name', 'SimulinkHandle', 'Parent', 'Kind', 'Ports',  ...
                'ReferenceName' };
            propgrp = matlab.mixin.util.PropertyGroup( proplist );
        end
    end

    methods ( Hidden, Static )
        function this = create( comp )

            this = autosar.arch.Component( comp );
        end
    end

    methods ( Hidden, Access = private )
        function this = Component( comp )
            this@autosar.arch.ComponentBase( comp );
        end
    end

    methods
        function name = get.ReferenceName( this )

            [ ~, name ] = autosar.arch.Utils.isModelBlock( this.SimulinkHandle );
        end

        function kind = get.Kind( this )

            m3iCompProto = autosar.composition.Utils.findM3ICompPrototypeForCompBlock(  ...
                this.SimulinkHandle );
            if m3iCompProto.isvalid(  ) && m3iCompProto.Type.isvalid(  )
                kind = m3iCompProto.Type.Kind.toString(  );
            end
        end

        function set.Kind( this, newKind )

            this.setKind( newKind );
        end

        function createModel( this, modelName, namedargs )

            arguments
                this
                modelName = get_param( this.SimulinkHandle, 'Name' )
                namedargs.BehaviorType{ mustBeMember( namedargs.BehaviorType, { 'ExportFunction', 'RateBased' } ) } = 'RateBased'
            end

            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>
                behaviorTypeEnum = systemcomposer.internal.arch.internal.ComponentImplementation.( namedargs.BehaviorType );
                this.createModelImpl( modelName, behaviorTypeEnum );
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end

        function linkToModel( this, modelName )

            narginchk( 1, 2 );

            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                isUIMode = false;
                this.linkToModelImpl( modelName, isUIMode );
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end

        function inlineComponent( this )



            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>

                systemComposerAPI = systemcomposer.arch.Model( bdroot( this.SimulinkHandle ) );
                zcComp = systemComposerAPI.lookup( 'Path', getfullname( this.SimulinkHandle ) );
                inlineContents = false;
                zcComp.inlineComponent( inlineContents );
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end

        function archObjs = find( this, category, varargin )

            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                this.checkValidSimulinkHandle(  );


                p = inputParser;
                p.addRequired( 'category', @( x )any( strcmp( x, { 'Port' } ) ) );
                p.addParameter( 'Name', '', @( x )ischar( x ) || isStringScalar( x ) );
                p.parse( category, varargin{ : } );

                switch ( category )
                    case 'Port'
                        sysH = autosar.arch.Finder.find( this.SimulinkHandle, category, varargin{ : } );
                        archObjs = autosar.arch.CompPort.empty(  );
                        if ~isempty( sysH )
                            archObjs = arrayfun( @( x )autosar.arch.CompPort.create( x ), sysH );
                        end
                    otherwise
                        assert( false, 'unsupported category %s for Component class', category );
                end
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end
    end

    methods ( Hidden, Access = public )

        function setKind( this, newKind )

            if autosar.arch.Utils.isModelBlock( this.SimulinkHandle )

                if ~bdIsLoaded( this.ReferenceName )
                    load_system( this.ReferenceName );
                end
                arProps = autosar.api.getAUTOSARProperties( this.ReferenceName );
                compQName = arProps.get( 'XmlOptions', 'ComponentQualifiedName' );
                arProps.set( compQName, 'Kind', newKind );


                autosar.arch.Utils.refreshModelBlocksReferencingModel(  ...
                    this.getRootArchModelH(  ), this.ReferenceName );
            else
                arProps = autosar.api.getAUTOSARProperties( this.getRootArchModelH(  ), true );
                m3iCompProto = autosar.composition.Utils.findM3ICompPrototypeForCompBlock( this.SimulinkHandle );
                compQName = autosar.api.Utils.getQualifiedName( m3iCompProto.Type );
                arProps.set( compQName, 'Kind', newKind );


                autosar.composition.studio.CompBlockUtils.refreshBlockIcon( this.SimulinkHandle );
            end


            this.refreshPropertyInspector(  );
        end
    end
end


