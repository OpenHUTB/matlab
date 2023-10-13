classdef ( Hidden, Abstract )ComponentBase < autosar.arch.ArchElement

    properties ( Dependent = true, SetAccess = private )
        Ports
    end

    methods
        function this = ComponentBase( comp )
            compH = get_param( comp, 'Handle' );
            this@autosar.arch.ArchElement( compH );


            assert( ( autosar.arch.Utils.isBlock( this.SimulinkHandle ) &&  ...
                autosar.composition.Utils.isComponentOrCompositionBlock( this.SimulinkHandle ) ) ||  ...
                ( autosar.arch.Utils.isBlockDiagram( this.SimulinkHandle ) &&  ...
                Simulink.internal.isArchitectureModel( this.SimulinkHandle, 'AUTOSARArchitecture' ) ),  ...
                '%s is not a Component or Composition.', getfullname( this.SimulinkHandle ) );
        end

        function ports = get.Ports( this )
            ports = this.find( 'Port' );
        end


        function ports = addPort( this, portKind, names )

            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                this.checkValidSimulinkHandle(  );

                if ~iscell( names )
                    names = { names };
                end


                portHs = cellfun( @( x )this.doAddPort( portKind, x ), names );


                ports = autosar.arch.PortBase.empty(  );
                if ~isempty( portHs )
                    ports = arrayfun( @( x )autosar.arch.PortBase.createPort( x ), portHs );
                end
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end

        function export( this, varargin )

            try
                cleanupObj = autosar.mm.util.MessageReporter.suppressWarningTrace(  );%#ok<NASGU>


                this.checkValidSimulinkHandle(  );

                autosar.api.export( getfullname( this.SimulinkHandle ),  ...
                    varargin{ : } );
            catch ME
                autosar.mm.util.MessageReporter.throwException( ME );
            end
        end
    end

    methods ( Hidden )
        function createModelImpl( this, modelNameWithPath, behaviorType, template, isUIMode )


            arguments
                this autosar.arch.ComponentBase;
                modelNameWithPath{ mustBeTextScalar, mustBeNonzeroLengthText };
                behaviorType( 1, 1 )systemcomposer.internal.arch.internal.ComponentImplementation =  ...
                    systemcomposer.internal.arch.internal.ComponentImplementation.RateBased;
                template{ mustBeTextScalar } = '';
                isUIMode( 1, 1 )logical = false;
            end

            import autosar.composition.studio.AUTOSARComponentToImplConverter


            this.checkValidSimulinkHandle(  );

            if autosar.arch.Utils.isModelBlock( this.SimulinkHandle )
                DAStudio.error( 'autosarstandard:api:ComponentIsAlreadyLinked',  ...
                    this.Name, this.ReferenceName );
            end

            [ modelPath, modelName, ~ ] = fileparts( modelNameWithPath );
            if isempty( modelPath )
                modelPath = pwd;
            end

            if ~isvarname( modelName )
                msgId = 'autosarstandard:editor:InvalidModelName';
                DAStudio.error( msgId, modelName );
            end
            compToModelConverter = AUTOSARComponentToImplConverter( this.SimulinkHandle,  ...
                modelName, modelPath, behaviorType, template, isUIMode );
            this.SimulinkHandle = compToModelConverter.convertComponentToImpl(  );
        end

        function linkToModelImpl( this, modelName, isUIMode )


            import autosar.composition.studio.AUTOSARComponentToModelLinker;


            this.checkValidSimulinkHandle(  );

            compToModelLinker = AUTOSARComponentToModelLinker( this.SimulinkHandle, modelName, isUIMode );

            compToModelLinker.validatePreLinking(  );

            this.SimulinkHandle = compToModelLinker.linkComponentToModel(  );
        end
    end

    methods ( Access = protected )
        function name = getName( this )

            name = this.getNameDefaultImpl(  );
        end

        function setName( this, newName )

            this.setNameDefaultImpl( newName );
        end

        function p = getParent( this )

            p = this.getParentDefaultImpl(  );
        end

        function destroyImpl( this )

            this.destroyDefaultImpl(  );
        end

        function setDefaultCompBlockSize( this, blk )%#ok<INUSL>



            curPos = get_param( blk, 'Position' );
            x = curPos( 1 );
            y = curPos( 2 );
            w = curPos( 3 ) - curPos( 1 );
            h = curPos( 4 ) - curPos( 2 );

            newPos = curPos;
            if w ~= 120
                newPos( 3 ) = x + 120;
            end
            if h ~= 100
                newPos( 4 ) = y + 100;
            end
            if ~isequal( curPos, newPos )
                set_param( blk, 'Position', newPos );
            end
        end
    end

    methods ( Access = private )
        function [ portH, portBlkH ] = doAddPort( this, portKind, portName )




            parentSysH = this.SimulinkHandle;


            p = inputParser;
            p.addRequired( 'parentSysH', @( x )autosar.arch.Utils.isBlockDiagram( x ) ||  ...
                autosar.arch.Utils.isSubSystem( x ) ||  ...
                autosar.arch.Utils.isModelBlock( x ) );


            p.addRequired( 'portKind', @( x )any( strcmp( x, { 'Sender', 'Receiver' } ) ) );
            p.addRequired( 'portName', @( x )ischar( x ) || isStringScalar( x ) );
            p.parse( parentSysH, portKind, portName );


            autosar.api.Utils.checkQualifiedName( bdroot( parentSysH ), portName, 'shortname' );


            if autosar.arch.Utils.isModelBlock( parentSysH )
                refModelName = autosar.arch.Utils.ensureRefModelLoaded( parentSysH );
                parentPath = refModelName;
            else

                parentPath = getfullname( parentSysH );
            end


            if ~isa( this, 'autosar.arch.Model' )
                ph1 = get_param( parentSysH, 'PortHandles' );
            end


            addBlockArgs = { 'MakeNameUnique', 'on',  ...
                'CreateNewPort', 'on', 'PortName', portName,  ...
                'Element', '' };





            SimulinkListenerAPI.clearUndoRedoARPropsCache(  );

            if strcmp( portKind, 'Sender' )
                portBlkH = add_block( 'simulink/Sinks/Out Bus Element',  ...
                    [ parentPath, '/Out Bus Element' ], addBlockArgs{ : } );
            else
                assert( strcmp( portKind, 'Receiver' ), 'Unexpected port kind: %s', portKind );



                dataInports = find_system( parentSysH, 'SearchDepth', 1,  ...
                    'BlockType', 'Inport', 'OutputFunctionCall', 'off' );
                portIdx = num2str( 1 + max( [ 0;arrayfun( @( p ) ...
                    str2double( get_param( p, 'Port' ) ), dataInports ) ] ) );

                portBlkH = add_block( 'simulink/Sources/In Bus Element',  ...
                    [ parentPath, '/In Bus Element' ], addBlockArgs{ : },  ...
                    'Port', portIdx );
            end




            if autosar.arch.Utils.isModelBlock( parentSysH )
                autosar.arch.Utils.refreshModelBlocksReferencingModel(  ...
                    this.getRootArchModelH(  ), refModelName );
            end

            if isa( this, 'autosar.arch.Model' )


                ph = get_param( portBlkH, 'PortHandles' );
                if strcmp( portKind, 'Sender' )
                    portH = ph.Inport;
                else
                    portH = ph.Outport;
                end
            else

                ph2 = get_param( parentSysH, 'PortHandles' );
                if strcmp( portKind, 'Sender' )
                    portH = setdiff( ph2.Outport, ph1.Outport );
                else
                    portH = setdiff( ph2.Inport, ph1.Inport );
                end
            end
        end
    end
end


