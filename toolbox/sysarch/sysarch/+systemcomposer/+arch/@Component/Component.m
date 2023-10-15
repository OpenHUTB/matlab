classdef Component < systemcomposer.arch.BaseComponent





    properties ( SetAccess = private )
        IsAdapterComponent
        Architecture
        ReferenceName
    end

    methods ( Hidden )
        function this = Component( archElemImpl )

            narginchk( 1, 1 );
            if ~isa( archElemImpl, 'systemcomposer.architecture.model.design.Component' )
                error( 'systemcomposer:API:ComponentInvalidInput', message( 'SystemArchitecture:API:ComponentInvalidInput' ).getString );
            end
            this@systemcomposer.arch.BaseComponent( archElemImpl );
            try

            catch


            end
        end

        function fullName = getQualifiedName( this )
            fullName = this.ElementImpl.getQualifiedName(  );
        end
    end


    methods
        function architecture = get.Architecture( this )
            if ( this.isReference &&  ...
                    ishandle( this.SimulinkHandle ) &&  ...
                    ~strcmp( this.ReferenceName, slInternal( 'getModelRefDefaultModelName' ) ) &&  ...
                    ~bdIsLoaded( this.ReferenceName ) &&  ...
                    ~isa( systemcomposer.internal.validator.getComponentBlockType( this.SimulinkHandle ), 'systemcomposer.internal.validator.ProtectedModelBehavior' ) )
                systemcomposer.loadModel( this.ReferenceName );
            end
            architecture = systemcomposer.internal.getWrapperForImpl( this.ElementImpl.getArchitecture, 'systemcomposer.arch.Architecture' );


            if this.ElementImpl.isSubsystemReferenceComponent &&  ...
                    systemcomposer.internal.isArchitectureLocked( architecture ) &&  ...
                    ~systemcomposer.internal.isArchitectureLocked( this.ElementImpl.getOwnedArchitecture )
                architecture = systemcomposer.internal.getWrapperForImpl( this.ElementImpl.getOwnedArchitecture );
            end
        end

        function mdlName = get.ReferenceName( this )
            if ( this.SimulinkHandle > 0 )
                if systemcomposer.internal.isSubsystemReferenceComponent( this.SimulinkHandle )
                    mdlName = get_param( this.SimulinkHandle, 'ReferencedSubsystem' );
                else
                    mdlName = get_param( this.SimulinkHandle, 'ModelNameInternal' );
                end
            else
                compImpl = this.getImpl;
                mdlName = compImpl.getArchitecture.getName;
            end
        end

        function isAdapt = get.IsAdapterComponent( this )
            isAdapt = this.getImpl.isAdapterComponent;
        end
    end

    methods
        function m = saveAsModel( this, modelFileName )




            m = this.createArchitectureModel( modelFileName );
        end

        function m = createArchitectureModel( this, modelFileName, architectureType, options )













            arguments
                this{ mustBeA( this, 'systemcomposer.arch.BaseComponent' ) }
                modelFileName{ mustBeTextScalar }
                architectureType{ mustBeTextScalar } = get_param( this.SimulinkHandle, 'SimulinkSubDomain' );
                options.Template{ mustBeTextScalar } = "";
            end

            systemcomposer.internal.validateArchitectureType( architectureType );

            if this.checkIfSupportedForAUTOSAR(  )
                modelName = get_param( bdroot( this.SimulinkHandle ), 'Name' );
                msgObj = message( 'SystemArchitecture:API:AUTOSARModelNotSupported', modelName );
                exception = MException( 'systemcomposer:API:AUTOSARModelNotSupported',  ...
                    msgObj.getString );
                throw( exception );
            end
            if this.isReference
                msgObj = message( 'SystemArchitecture:API:ComponentAlreadyReference' );
                exception = MException( 'systemcomposer:API:ComponentAlreadyReference',  ...
                    msgObj.getString );
                throw( exception );
            end
            if systemcomposer.internal.isInlinedSubsystemBehavior( this.SimulinkHandle )
                msgObj = message( 'SystemArchitecture:API:BehaviorComponentCannotBeArchitecture' );
                exception = MException( 'systemcomposer:API:BehaviorComponentCannotBeArchitecture',  ...
                    msgObj.getString );
                throw( exception );
            end





            if strcmpi( architectureType, 'Architecture' ) &&  ...
                    this.Architecture.getImpl(  ).isSoftwareArchitecture(  )
                throw( MSLException(  ...
                    'SystemArchitecture:SoftwareArchitecture:CannotCreateSystemArchitecture' ) );
            end

            bh = this.SimulinkHandle;


            if ~isempty( find_system( bh, 'SearchDepth', 1, 'BlockType', 'PMIOPort' ) )
                msgObj = message( 'SystemArchitecture:SaveAndLink:PhysicalConnectionCannotCrossModelBoundary' );
                exception = MException( 'systemcomposer:SaveAndLink:PhysicalConnectionCannotCrossModelBoundary',  ...
                    msgObj.getString );
                throw( exception );
            end

            slmh = this.SimulinkModelHandle;
            [ fp, fn ] = fileparts( modelFileName );



            targetModelValidator = systemcomposer.internal.TargetModelValidator( fn, fp );
            targetModelValidator.validate( true );

            if strcmpi( architectureType, 'Architecture' ) ||  ...
                    strcmpi( architectureType, get_param( this.SimulinkHandle, 'SimulinkSubDomain' ) )




                converter =  ...
                    systemcomposer.internal.arch.internal.ComponentToReferenceConverter(  ...
                    bh, fn, fp, options.Template );
            elseif strcmpi( architectureType, 'SoftwareArchitecture' )
                converter =  ...
                    systemcomposer.internal.arch.internal.ComponentToSoftwareArchitectureConverter(  ...
                    bh, fn, systemcomposer.internal.CommandLineErrorReporter(  ), fp, options.Template );
            else
                assert( false, 'unreachable, architecture should have been validated' );
            end

            try
                mbh = converter.convertComponentToReference(  );
            catch ex
                throwAsCaller( ex );
            end

            systemcomposer.internal.arch.internal.processBatchedPluginEvents( slmh );
            m = systemcomposer.loadModel( get_param( mbh, "ModelName" ) );
        end

        function mh = createSimulinkBehavior( this, modelFileName, options )






            arguments
                this;
                modelFileName = "";
                options.Type{ mustBeTextScalar, mustBeValidType } = "";
                options.Template{ mustBeTextScalar } = "";
                options.BehaviorType{ mustBeTextScalar, mustBeValidBehaviorType } = "";
            end

            import systemcomposer.internal.arch.internal.*;

            if options.Type == "SubsystemReference" && slfeature( 'ZCSubsystemReference' ) == 0
                msgObj = message( 'SystemArchitecture:API:CannotLinkToSubsystemReference' );
                exception = MException( 'systemcomposer:API:CannotLinkToSubsystemReference',  ...
                    msgObj.getString );
                throw( exception );
            end
            if this.isReference
                msgObj = message( 'SystemArchitecture:API:ComponentAlreadyReference' );
                exception = MException( 'systemcomposer:API:ComponentAlreadyReference',  ...
                    msgObj.getString );
                throw( exception );
            end
            if ~isempty( this.Architecture.Components )
                msgObj = message( 'SystemArchitecture:API:ComponentNotEmptyForBehavior' );
                exception = MException( 'systemcomposer:API:ComponentNotEmptyForBehavior',  ...
                    msgObj.getString );
                throw( exception );
            end

            isSWArch = Simulink.internal.isArchitectureModel( this.SimulinkModelHandle, 'SoftwareArchitecture' );
            if ~isSWArch && options.BehaviorType ~= ""
                warning( message( 'SystemArchitecture:API:WarningBehaviorTypeNotSupported' ) );
            end

            bh = this.SimulinkHandle;


            physicalPortExists = ~isempty( find_system( bh, 'SearchDepth', 1, 'BlockType', 'PMIOPort' ) );


            if options.Type == ""
                if physicalPortExists
                    options.Type = "SubsystemReference";
                else
                    options.Type = "ModelReference";
                end
            end

            isInlinedSubsystem = systemcomposer.internal.isInlinedSubsystemBehavior( this.SimulinkHandle );
            if ( isInlinedSubsystem && options.Type ~= "SubsystemReference" ) ||  ...
                    systemcomposer.internal.isStateflowBehaviorComponent( this.SimulinkHandle )
                msgObj = message( 'SystemArchitecture:API:ComponentAlreadyBehavior' );
                exception = MException( 'systemcomposer:API:ComponentAlreadyBehavior',  ...
                    msgObj.getString );
                throw( exception );
            end

            if physicalPortExists && options.Type == "ModelReference"
                msgObj = message( 'SystemArchitecture:SaveAndLink:PhysicalConnectionCannotCrossModelBoundary' );
                exception = MException( 'systemcomposer:SaveAndLink:PhysicalConnectionCannotCrossModelBoundary',  ...
                    msgObj.getString );
                throw( exception );
            end

            if this.checkIfSupportedForAUTOSAR(  ) && options.Type ~= "ModelReference"
                msgObj = message( 'SystemArchitecture:API:InvalidBehaviorType', options.Type, "ModelReference" );
                exception = MException( 'systemcomposer:API:InvalidBehaviorType',  ...
                    msgObj.getString );
                throw( exception );
            end

            slmh = this.SimulinkModelHandle;
            if options.Type ~= "Subsystem"
                [ fp, fn ] = fileparts( modelFileName );



                targetModelValidator = systemcomposer.internal.TargetModelValidator( fn, fp );
                targetModelValidator.validate( true );
            end

            try

                if isSWArch
                    converter = SoftwareComponentToImplConverter( bh, fn, fp, options.Template );
                    if strcmpi( options.BehaviorType, "RateBased" )
                        converter.ImplementComponentAs = ComponentImplementation.RateBased;
                    elseif strcmpi( options.BehaviorType, "ExportFunction" )
                        converter.ImplementComponentAs = ComponentImplementation.ExportFunction;
                    end
                else
                    if options.Type == "SubsystemReference"
                        if isInlinedSubsystem
                            converter = SubsystemToSubsystemReferenceConverter( bh, fn, fp );
                        else
                            converter = ComponentToSubsystemReferenceConverter( bh, fn, fp );
                        end
                    elseif options.Type == "Subsystem"
                        converter = systemcomposer.internal.arch.internal.ComponentToImplSubsystemConverter( bh );
                    else
                        if this.checkIfSupportedForAUTOSAR(  )
                            behaviorType = systemcomposer.internal.arch.internal.ComponentImplementation.RateBased;
                            converter = autosar.composition.studio.AUTOSARComponentToImplConverter( bh, fn, fp, behaviorType, options.Template, false );
                        else
                            converter = ComponentToImplConverter( bh, fn, fp, options.Template );
                        end
                    end
                end

                newBlockHdl = converter.convertComponentToImpl(  );
            catch ex
                throwAsCaller( ex );
            end

            systemcomposer.internal.arch.internal.processBatchedPluginEvents( slmh );
            if options.Type == "Subsystem"
                mh = bh;
            else

                mh = get_param( systemcomposer.internal.getReferenceName( newBlockHdl ), 'Handle' );
            end
        end

        function mh = createStateflowChartBehavior( this )







            if this.checkIfSupportedForAUTOSAR(  )
                modelName = get_param( bdroot( this.SimulinkHandle ), 'Name' );
                msgObj = message( 'SystemArchitecture:API:AUTOSARModelNotSupported', modelName );
                exception = MException( 'systemcomposer:API:AUTOSARModelNotSupported',  ...
                    msgObj.getString );
                throw( exception );
            end
            if ~dig.isProductInstalled( 'Stateflow' )
                msgObj = message( 'SystemArchitecture:API:StateflowLicenseError' );
                exception = MException( 'systemcomposer:API:StateflowLicenseError',  ...
                    msgObj.getString );
                throw( exception );
            end
            if this.isReference
                msgObj = message( 'SystemArchitecture:API:ComponentAlreadyReference' );
                exception = MException( 'systemcomposer:API:ComponentAlreadyReference',  ...
                    msgObj.getString );
                throw( exception );
            end
            if systemcomposer.internal.isInlinedSubsystemBehavior( this.SimulinkHandle )
                msgObj = message( 'SystemArchitecture:API:InlinedSubsystemBehaviorsCannotBeStateflow' );
                exception = MException( 'systemcomposer:API:InlinedSubsystemBehaviorsCannotBeStateflow',  ...
                    msgObj.getString );
                throw( exception );
            end
            if ~isempty( this.Architecture.Components )
                msgObj = message( 'SystemArchitecture:API:NonEmptyComponentConversionToStateflow' );
                exception = MException( 'systemcomposer:API:NonEmptyComponentConversionToStateflow',  ...
                    msgObj.getString );
                throw( exception );
            end
            if ~strcmp( get_param( this.SimulinkHandle, 'SimulinkSubDomain' ), 'Architecture' )
                msgObj = message( 'SystemArchitecture:API:StateflowForUnsupportedDomain' );
                exception = MException( 'systemcomposer:API:StateflowForUnsupportedDomain',  ...
                    msgObj.getString );
                throw( exception );
            end

            bh = this.SimulinkHandle;


            if ~isempty( find_system( bh, 'SearchDepth', 1, 'BlockType', 'PMIOPort' ) )
                msgObj = message( 'SystemArchitecture:SaveAndLink:PhysicalConnectionCannotCrossModelBoundary' );
                exception = MException( 'systemcomposer:SaveAndLink:PhysicalConnectionCannotCrossModelBoundary',  ...
                    msgObj.getString );
                throw( exception );
            end

            slmh = this.SimulinkModelHandle;

            try
                compToChartImplConverter = systemcomposer.internal.arch.internal.ComponentToChartImplConverter( bh );
                mbh = compToChartImplConverter.convertComponentToChartImpl(  );
            catch ex
                throwAsCaller( ex );
            end

            systemcomposer.internal.arch.internal.processBatchedPluginEvents( slmh );
            mh = get_param( getfullname( mbh ), 'Handle' );
        end

        function bh = createSubsystemBehavior( this )






            if this.checkIfSupportedForAUTOSAR(  )
                modelName = get_param( bdroot( this.SimulinkHandle ), 'Name' );
                msgObj = message( 'SystemArchitecture:API:AUTOSARModelNotSupported', modelName );
                exception = MException( 'systemcomposer:API:AUTOSARModelNotSupported',  ...
                    msgObj.getString );
                throw( exception );
            end

            if this.isReference
                msgObj = message( 'SystemArchitecture:API:ComponentAlreadyReference' );
                exception = MException( 'systemcomposer:API:ComponentAlreadyReference',  ...
                    msgObj.getString );
                throw( exception );
            end

            if systemcomposer.internal.isInlinedSubsystemBehavior( this.SimulinkHandle ) ||  ...
                    systemcomposer.internal.isStateflowBehaviorComponent( this.SimulinkHandle )
                msgObj = message( 'SystemArchitecture:API:ComponentAlreadyBehavior' );
                exception = MException( 'systemcomposer:API:ComponentAlreadyBehavior',  ...
                    msgObj.getString );
                throw( exception );
            end

            if ~isempty( this.Architecture.Components )
                msgObj = message( 'SystemArchitecture:API:ComponentNotEmptyForBehavior' );
                exception = MException( 'systemcomposer:API:ComponentNotEmptyForBehavior',  ...
                    msgObj.getString );
                throw( exception );
            end

            compToImplConverter = systemcomposer.internal.arch.internal.ComponentToImplSubsystemConverter( this.SimulinkHandle );
            bh = compToImplConverter.convert(  );

            systemcomposer.internal.arch.internal.processBatchedPluginEvents( this.SimulinkModelHandle );
            bh = get_param( getfullname( bh ), 'Handle' );

        end

        function m = createArchitectureSubsystem( this, ssRefFileName )

            arguments
                this{ mustBeA( this, 'systemcomposer.arch.BaseComponent' ) }
                ssRefFileName{ mustBeTextScalar }
            end

            if this.isReference
                msgObj = message( 'SystemArchitecture:API:ComponentAlreadyReference' );
                exception = MException( 'systemcomposer:API:ComponentAlreadyReference',  ...
                    msgObj.getString );
                throw( exception );
            end
            if systemcomposer.internal.isInlinedSubsystemBehavior( this.SimulinkHandle ) ||  ...
                    systemcomposer.internal.isStateflowBehaviorComponent( this.SimulinkHandle )
                msgObj = message( 'SystemArchitecture:API:BehaviorComponentCannotBeArchitecture' );
                exception = MException( 'systemcomposer:API:BehaviorComponentCannotBeArchitecture',  ...
                    msgObj.getString );
                throw( exception );
            end

            bh = this.SimulinkHandle;

            slmh = this.SimulinkModelHandle;
            [ fp, fn ] = fileparts( ssRefFileName );



            targetModelValidator = systemcomposer.internal.TargetModelValidator( fn, fp );
            targetModelValidator.validate( true );



            converter =  ...
                systemcomposer.internal.arch.internal.ComponentToArchitectureSubsystemReferenceConverter(  ...
                bh, fn, fp );

            try
                mbh = converter.convert(  );
            catch ex
                throwAsCaller( ex );
            end

            systemcomposer.internal.arch.internal.processBatchedPluginEvents( slmh );
            m = systemcomposer.loadModel( get_param( mbh, "ReferencedSubsystem" ) );
        end

        function mh = linkToModel( this, modelFileName )






            if ~this.isReference && ~isempty( this.Architecture.Components )

                msgObj = message( 'SystemArchitecture:API:ComponentNotEmptyForLink' );
                exception = MException( 'systemcomposer:API:ComponentNotEmptyForLink',  ...
                    msgObj.getString );
                throw( exception );
            end
            bh = this.SimulinkHandle;
            mh =  - 1;
            if this.isReference && strcmp( this.ReferenceName, modelFileName )



                try
                    mh = get_param( this.ReferenceName, 'Handle' );
                catch ME
                    switch ME.identifier
                        case 'Simulink:Commands:InvSimulinkObjectName'


                        otherwise
                            rethrow( ME )
                    end
                end
                return ;
            end
            if systemcomposer.internal.isInlinedSubsystemBehavior( this.SimulinkHandle ) ||  ...
                    systemcomposer.internal.isStateflowBehaviorComponent( this.SimulinkHandle )
                msgObj = message( 'SystemArchitecture:API:InlinedSubsystemBehaviorsCannotBeLinked' );
                exception = MException( 'systemcomposer:API:InlinedSubsystemBehaviorsCannotBeLinked',  ...
                    msgObj.getString );
                throw( exception );
            end

            slmh = this.SimulinkModelHandle;

            existKey = exist( modelFileName, 'file' );
            isSubsystemFile = false;
            if existKey == 4
                try
                    modelInfo = Simulink.MDLInfo( modelFileName );
                    diagramType = modelInfo.BlockDiagramType;
                catch ME
                    switch ME.identifier
                        case 'Simulink:LoadSave:FileNotFound'


                            load_system( modelFileName );
                            diagramType = get_param( modelFileName, 'BlockDiagramType' );
                        otherwise
                            rethrow( ME )
                    end
                end
                isSubsystemFile = strcmpi( diagramType, 'subsystem' );
                if strcmpi( diagramType, 'library' )

                    error( message( 'SystemArchitecture:SaveAndLink:OnlyModelsAllowedForLinking' ) );
                end
            else
                error( message( 'SystemArchitecture:SaveAndLink:OnlyModelsAllowedForLinking' ) );
            end


            isSubsystemComponent = systemcomposer.internal.isSubsystemReferenceComponent( bh );
            isModelComponent = strcmp( 'ModelReference', get_param( bh, 'BlockType' ) );
            if isSubsystemFile
                if ~( slfeature( 'ZCSubsystemReference' ) > 0 )
                    error( message( 'SystemArchitecture:API:CannotLinkToSubsystemReference' ) );
                end
                if isModelComponent
                    error( message( 'SystemArchitecture:API:ModelCannotConvert2SubsystemRef' ) );
                end
                if this.checkIfSupportedForAUTOSAR(  )
                    error( message( 'SystemArchitecture:API:LinkModelError', modelFileName ) );
                end
                compToSubsystemLinker =  ...
                    systemcomposer.internal.arch.internal.ComponentToSubsystemReferenceLinker( bh, modelFileName );
                mbh = compToSubsystemLinker.linkComponentToSubsystemReference(  );
            else
                if isSubsystemComponent
                    error( message( 'SystemArchitecture:API:SubsystemRefCannotConvert2Model' ) );
                end
                if this.checkIfSupportedForAUTOSAR(  )
                    compToModelLinker =  ...
                        autosar.composition.studio.AUTOSARComponentToModelLinker( bh, modelFileName, false );
                    compToModelLinker.validatePreLinking(  );
                else
                    compToModelLinker =  ...
                        systemcomposer.internal.arch.internal.ComponentToModelLinker( bh, modelFileName );
                end
                mbh = compToModelLinker.linkComponentToModel(  );
            end

            systemcomposer.internal.arch.internal.processBatchedPluginEvents( slmh );


            if isSubsystemFile
                mh = get_param( get_param( mbh, "ReferencedSubsystem" ), 'Handle' );
            else
                if ( strcmpi( get_param( mbh, "ProtectedModel" ), 'off' ) )
                    mh = get_param( get_param( mbh, "ModelNameInternal" ), 'Handle' );
                end
            end
        end

        function c = inlineComponent( this, inlineContents )










            if ~( this.isReference || systemcomposer.internal.isStateflowBehaviorComponent( this.SimulinkHandle ) ||  ...
                    systemcomposer.internal.isInlinedSubsystemBehavior( this.SimulinkHandle ) )


                msgObj = message( 'SystemArchitecture:API:ComponentNeedsToBeRefOrBeh' );
                exception = MException( 'systemcomposer:API:ComponentNeedsToBeRefOrBeh',  ...
                    msgObj.getString );
                throw( exception );
            else
                [ allowInlining, componentBlockType, isReference, isBehavior ] =  ...
                    systemcomposer.internal.validator.ConversionUIValidator.canInline( this.SimulinkHandle );

                invalidRef = isa( componentBlockType, 'systemcomposer.internal.validator.ModelUnspecified' ) ||  ...
                    isa( componentBlockType, 'systemcomposer.internal.validator.SubsystemReferenceUnspecified' ) ||  ...
                    ( isa( componentBlockType, 'systemcomposer.internal.validator.ProtectedModelBehavior' ) && ~allowInlining );

                if ~allowInlining
                    if invalidRef
                        msgObj = message( 'SystemArchitecture:API:InliningErrorInvalidModelRef' );
                        exception = MException( 'systemcomposer:API:InliningErrorInvalidModelRef',  ...
                            msgObj.getString );
                        throw( exception );
                    else
                        msgObj = message( 'SystemArchitecture:API:InliningErrorDifferentDomains' );
                        exception = MException( 'systemcomposer:API:InliningErrorDifferentDomains',  ...
                            msgObj.getString );
                        throw( exception );
                    end
                else
                    if ( isBehavior && inlineContents )

                        if isa( componentBlockType, 'systemcomposer.internal.validator.Stateflow' )
                            msgObj = message( 'SystemArchitecture:API:InliningErrorChartBehaviorContents' );
                            exception = MException( 'systemcomposer:API:InliningErrorChartBehaviorContents',  ...
                                msgObj.getString );
                            throw( exception );
                        else

                            if isReference
                                msgObj = message( 'SystemArchitecture:API:InliningErrorSimulinkBehaviorContents' );
                                exception = MException( 'systemcomposer:API:InliningErrorSimulinkBehaviorContents',  ...
                                    msgObj.getString );
                                throw( exception );

                            else
                                msgObj = message( 'SystemArchitecture:API:BehaviorComponentsCannotInlineContents' );
                                exception = MException( 'systemcomposer:API:BehaviorComponentsCannotInlineContents',  ...
                                    msgObj.getString );
                                throw( exception );
                            end
                        end
                    end
                end
            end

            zcm = this.Model;
            slmh = this.SimulinkModelHandle;
            bh = this.SimulinkHandle;
            cbh = systemcomposer.internal.arch.internal.inlineComponent( bh, inlineContents );
            systemcomposer.internal.arch.internal.processBatchedPluginEvents( slmh );
            c = zcm.lookup( 'SimulinkHandle', cbh );
        end

        function destroy( this )
            destroy@systemcomposer.arch.BaseComponent( this );
        end

        function [ propExpr, propUnits ] = getProperty( this, qualifiedPropName )







            [ propExpr, propUnits ] = getProperty@systemcomposer.arch.Element( this.Architecture, qualifiedPropName );
        end

        function setProperty( this, qualifiedPropName, propExpr, propUnit )






            if nargin < 4
                propUnit = '';
            end
            setProperty@systemcomposer.arch.Element( this.Architecture, qualifiedPropName, propExpr, propUnit );
        end

        function val = getPropertyValue( this, qualifiedPropName )





            val = getPropertyValue( this.Architecture, qualifiedPropName );
        end

        function value = getEvaluatedPropertyValue( this, qualifiedPropName )






            value = getEvaluatedPropertyValue( this.Architecture, qualifiedPropName );
        end

        function [ variantComp, choices ] = makeVariant( this, varargin )































            if this.checkIfSupportedForAUTOSAR(  )
                modelName = get_param( bdroot( this.SimulinkHandle ), 'Name' );
                msgObj = message( 'SystemArchitecture:API:AUTOSARModelNotSupported', modelName );
                exception = MException( 'systemcomposer:API:AUTOSARModelNotSupported',  ...
                    msgObj.getString );
                throw( exception );
            end

            variantComp = [  ];
            choices = [  ];
            variantBlockHdls = systemcomposer.internal.arch.internal.convertComponentsToVariants( this.SimulinkHandle );
            for i = 1:numel( variantBlockHdls )
                cImpl = systemcomposer.utils.getArchitecturePeer( variantBlockHdls( i ) );
                variantComp = [ variantComp, systemcomposer.internal.getWrapperForImpl( cImpl, 'systemcomposer.arch.VariantComponent' ) ];
                for m = 1:2:numel( varargin )
                    propName = varargin{ m };
                    switch propName
                        case 'Name'
                            variantComp.Name = varargin{ m + 1 };
                        case 'Label'
                            variantComp.setCondition( this, varargin{ m + 1 } );
                        case 'Choices'
                            lblOption = cellfun( @( x )strcmpi( x, 'ChoiceLabels' ), varargin( 1:2:end  ), 'UniformOutput', false );
                            lblOption = [ lblOption{ : } ];
                            if any( lblOption )
                                idx = find( lblOption == 1 );








                                labels = varargin{ idx * 2 };
                                try
                                    variantComp.addChoice( varargin{ m + 1 }, labels );
                                catch ex

                                    throw( ex )
                                end
                            else
                                variantComp.addChoice( varargin{ m + 1 } );
                            end
                        otherwise


                            if strcmpi( propName, 'ChoiceLabels' )
                                found = cellfun( @( x )strcmpi( x, 'Choices' ), varargin( 1:2:end  ), 'UniformOutput', false );
                                if ~any( [ found{ : } ] )
                                    error( 'systemcomposer:API:makeVariantChoiceLabel', message( 'SystemArchitecture:API:makeVariantChoiceLabel' ).getString );
                                end
                            end
                    end
                end
                choices = [ choices, variantComp( end  ).getChoices ];
            end
        end

    end


    methods ( Hidden )
        comp = makeReference( this, fileName, varargin );
        behaviorComp = createBehavior( this, behaviorOptions );

        function value = getCustomPropertyValue( this, propObj )
            value = eval( systemcomposer.internal.arch.getPropertyValue( this.Architecture, propObj.propertySet.getName, propObj.getName ) );
            if iscell( value )
                value = string( value );
            end
        end

        function setCustomPropertyValue( this, propObj, value )
            t = this.MFModel.beginTransaction;
            this.Architecture.getImpl.setPropVal( [ propObj.propertySet.getName, '.', propObj.getName ], value );
            t.commit;
        end

        function refreshArchitecture( this )

            if this.Architecture.Definition == systemcomposer.arch.ArchitectureDefinition.Behavior

                this.getImpl.setArchitecture( this.Architecture.getImpl );
            end
        end

        function tf = checkIfSupportedForAUTOSAR( this )

            tf = Simulink.internal.isArchitectureModel( bdroot( this.SimulinkHandle ), 'AUTOSARArchitecture' );
        end

    end

    methods ( Access = protected )
        function propObj = getPropertyImpl( this, protoName, propName )
            psUsage = findobj( this.Architecture.getImpl.PropertySets.toArray, 'p_Name', protoName );
            propObj = findobj( psUsage.properties.toArray, 'p_Name', propName );
        end
    end

end

function mustBeValidBehaviorType( typeString )


validTypes = [ "RateBased", "ExportFunction" ];


if typeString ~= "" && ~any( strcmpi( typeString, validTypes ) )
    validOpts = sprintf( "'%s'", strjoin( validTypes, "', '" ) );
    errMessage = message( 'SystemArchitecture:API:InvalidBehaviorType', typeString, validOpts );
    throwAsCaller( MException( errMessage ) );
end

end

function mustBeValidType( typeString )

validTypes = [ "ModelReference", "SubsystemReference", "Subsystem" ];


if typeString ~= "" && ~any( strcmpi( typeString, validTypes ) )
    validOpts = sprintf( "'%s'", strjoin( validTypes, "', '" ) );
    errMessage = message( 'SystemArchitecture:API:InvalidBehaviorType', typeString, validOpts );
    throwAsCaller( MException( errMessage ) );
end
end





