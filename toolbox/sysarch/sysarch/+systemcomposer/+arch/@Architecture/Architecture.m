classdef Architecture < systemcomposer.arch.Element & systemcomposer.base.BaseArchitecture






    properties
        Name;
    end

    properties ( SetAccess = private )
        Definition
        Parent
        Components
        Ports
        Connectors
        Parameters
    end

    properties ( Hidden )
        AliasName;
    end

    methods ( Static )
        function obj = current(  )
            try
                impl = systemcomposer.utils.getArchitecturePeer( get_param( gcs, 'handle' ) );
                obj = systemcomposer.internal.getWrapperForImpl( impl, 'systemcomposer.arch.Architecture' );
            catch
                obj = systemcomposer.arch.Architecture.empty;
            end
        end
    end

    methods ( Hidden )
        function this = Architecture( archElemImpl )
            if ~isa( archElemImpl, 'systemcomposer.architecture.model.design.Architecture' )
                error( 'systemcomposer:API:ArchitectureInvalidInput', message(  ...
                    'SystemArchitecture:API:ArchitectureInvalidInput' ).getString );
            end

            this@systemcomposer.arch.Element( archElemImpl );
            archElemImpl.cachedWrapper = this;

            if archElemImpl.hasTrait( systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass )
                this.addFunctionProp(  );
            end
        end

        function fullName = getQualifiedName( this )
            fullName = this.ElementImpl.getName;
            if ~isempty( this.Parent )
                fullName = this.Parent.getQualifiedName(  );
            end
        end

        function ports = getActivePorts( this )

            if ~isempty( this.Parent )
                activeCompPorts = this.Parent.getActivePorts;
                ports = systemcomposer.arch.ArchitecturePort.empty( numel( activeCompPorts ), 0 );
                cnt = 1;
                for i = 1:numel( activeCompPorts )
                    p = this.getPort( activeCompPorts( i ).Name );
                    if ~isempty( p )
                        ports( cnt ) = p;
                        cnt = cnt + 1;
                    end
                end
            else
                ports = this.Ports;
            end
        end

        function conn = getActiveConnectors( this )


            cn = this.Connectors;
            conn = systemcomposer.arch.Connector.empty( numel( cn ), 0 );
            cnt = 1;
            for m = 1:numel( cn )
                ports = cn( m ).Ports;
                activePortSum = 0;
                for n = 1:numel( ports )
                    activePorts = ports( n ).Parent.getActivePorts;
                    isPortActive = any( arrayfun( @( x )isequal( x, ports( n ) ), activePorts ) );
                    if ( isPortActive )
                        activePortSum = activePortSum + 1;
                    end
                end
                if activePortSum == numel( ports )
                    conn( cnt ) = cn( m );
                    cnt = cnt + 1;
                end
            end
        end

        function destroy( ~ )

            error( 'systemcomposer:API:ArchitectureCannotDestroy',  ...
                message( 'SystemArchitecture:API:ArchitectureCannotDestroy' ).getString );
        end

        function layout( this )



            slhdl = this.SimulinkHandle;
            if ~isempty( slhdl )
                Simulink.BlockDiagram.arrangeSystem( slhdl );
            end
        end

        function comp = getComponent( this, name )

            comp = systemcomposer.internal.getWrapperForImpl( this.ElementImpl.getComponent( name ) );
        end

        function port = getPort( this, name )

            port = systemcomposer.arch.ArchitecturePort.empty;
            portObj = this.ElementImpl.getPort( name );
            if ( ~isempty( portObj ) )
                port = systemcomposer.internal.getWrapperForImpl( portObj );
            end
        end

        function addPrototype( this )
            addPrototype@systemcomposer.arch.Element( this );
            if ~isempty( this.Parent )
                this.Parent.addDynamicProperties( this.getImpl );
            end
        end

        function removePrototype( this )
            removePrototype@systemcomposer.base.StereotypableElement( this );
            if ~isempty( this.Parent )
                this.Parent.removeDynamicProperties( this.getImpl );
            end
        end

        function addPrototypeProperties( this, protoName, propName )
            addPrototypeProperties@systemcomposer.base.StereotypableElement( this, protoName, propName );
            if ~isempty( this.Parent )
                addPrototypeProperties@systemcomposer.base.StereotypableElement( this.Parent, protoName, propName );
            end
        end

        function removePrototypeProperties( this, protoName, propName )
            removePrototypeProperties@systemcomposer.base.StereotypableElement( this, protoName, propName );
            if ~isempty( this.Parent )
                removePrototypeProperties@systemcomposer.base.StereotypableElement( this.Parent, protoName, propName );
            end
        end

        function updatePrototypePropertyName( this, protoName, oldPropName, newPropName )
            updatePrototypePropertyName@systemcomposer.base.StereotypableElement( this, protoName, oldPropName, newPropName );
            if ~isempty( this.Parent )
                updatePrototypePropertyName@systemcomposer.base.StereotypableElement( this.Parent, protoName, oldPropName, newPropName );
            end
        end

        function updatePrototypeName( this, oldName, newName )
            updatePrototypeName@systemcomposer.base.StereotypableElement( this, oldName, newName );
            if ~isempty( this.Parent )
                updatePrototypeName@systemcomposer.base.StereotypableElement( this.Parent, oldName, newName );
            end
        end

        function [ val, unit ] = getDefaultParameterValue( this, paramFQN )
            def = this.getParameterDefinition( paramFQN );
            val = '';
            unit = '';
            if ~isempty( def )
                defaultVal = def.getImpl.defaultValue;
                val = defaultVal.expression;
                unit = defaultVal.units;
            end
        end

        function removeParameter( this, name )
            if isempty( this.Parent )
                mWksp = get_param( this.Name, 'ModelWorkspace' );
                if isvarname( name )
                    if mWksp.hasVariable( name )
                        mWksp.clear( name );
                    else

                        this.getImpl.removeParameter( name );
                    end
                else

                    impl = this.getImpl;
                    exportedParamMap = impl.getExportedParameters;
                    exportedParamMap.removeUUIDParamPairByParamName( name );
                end
            else
                mask = get_param( this.SimulinkHandle, 'MaskObject' );
                mask.removeParameter( name );
            end
        end

        function setParameterName( this, oldName, newName )
            if isempty( this.Parent )
                mWksp = get_param( this.Name, 'ModelWorkspace' );
                if mWksp.hasVariable( oldName )
                    param = mWksp.getVariable( oldName );
                    if isa( param, 'Simulink.Parameter' )
                        mWksp.assignin( newName, param );
                        mWksp.clear( oldName );
                    else

                    end
                end
            else
                mask = get_param( this.SimulinkHandle, 'MaskObject' );
                mp = mask.getParameter( oldName );
                mp.Name = newName;
            end
        end

        function pd = getParameterDefinition( this, name )
            pDefImpl = this.getImpl.getParameterDefinition( name );
            pd = systemcomposer.ValueType.empty;
            paramName = name;
            if isempty( pDefImpl )
                if ( this.getImpl.isPromotedParameter( name ) )
                    compImpl = this.getImpl.getComponentPromotedFrom( name );
                    if ~isempty( compImpl )
                        owner = systemcomposer.internal.getWrapperForImpl( compImpl.getArchitecture );
                        ownerRelPath = regexprep( owner.getQualifiedName, [ '^', this.getQualifiedName, '/' ], '' );
                        paramName = string( regexprep( paramName, [ '^', ownerRelPath ], '' ) );
                        if paramName.startsWith( '.' )
                            paramName = paramName.extractAfter( '.' );
                        end
                        if paramName.startsWith( '/' )
                            paramName = paramName.extractAfter( '/' );
                        end
                        pd = owner.getParameterDefinition( paramName );
                    end
                end
            end
            if ~isempty( pDefImpl )
                pd = systemcomposer.internal.getWrapperForImpl( pDefImpl );
                if isempty( pd ) || ( ~isempty( pd ) && ~isvalid( pd.Owner ) )
                    owner = this;
                    if ( this.getImpl.isPromotedParameter( name ) )
                        compImpl = this.getImpl.getComponentPromotedFrom( name );
                        if ~isempty( compImpl )
                            owner = systemcomposer.internal.getWrapperForImpl( compImpl.getArchitecture );
                        end
                    end
                    pd = systemcomposer.ValueType( pDefImpl, owner );

                end
            end
        end

        comp = addReferenceComponent( this, compName, varargin );
        exposeParameter( this, varargin );
        unexposeParameter( this, varargin );
        validateAPISupportForAUTOSAR( this, fcnName );

    end

    methods
        function name = get.Name( this )
            name = this.ElementImpl.getName(  );
        end

        function set.Name( this, newName )
            slHndl = this.SimulinkHandle;
            if ~isempty( slHndl )

                set_param( slHndl, 'Name', newName );
            end
        end

        function defn = get.Definition( this )
            implDef = this.getImpl.getDefinition;
            if implDef == systemcomposer.architecture.model.core.DefinitionType.BEHAVIOR
                if isa( this.getImpl, 'systemcomposer.architecture.model.sldomain.StateflowArchitecture' )
                    defn = systemcomposer.arch.ArchitectureDefinition.StateflowBehavior;
                else
                    defn = systemcomposer.arch.ArchitectureDefinition.Behavior;
                end
            else
                defn = systemcomposer.arch.ArchitectureDefinition.Composition;
            end
        end


        function children = get.Components( this )
            ch = this.ElementImpl.getComponents(  );
            children = systemcomposer.arch.Component.empty( numel( ch ), 0 );
            for i = 1:numel( ch )
                if isa( ch( i ), 'systemcomposer.architecture.model.design.VariantComponent' )
                    children( i ) = systemcomposer.internal.getWrapperForImpl( ch( i ), 'systemcomposer.arch.VariantComponent' );
                else
                    children( i ) = systemcomposer.internal.getWrapperForImpl( ch( i ), 'systemcomposer.arch.Component' );
                end
            end
        end

        function ports = get.Ports( this )
            ch = this.ElementImpl.getPorts(  );
            ports = systemcomposer.arch.ArchitecturePort.empty( numel( ch ), 0 );
            for i = 1:numel( ch )
                ports( i ) = systemcomposer.internal.getWrapperForImpl( ch( i ), 'systemcomposer.arch.ArchitecturePort' );
            end
        end

        function conn = get.Connectors( this )
            ch = this.ElementImpl.getConnectors(  );
            conn = systemcomposer.arch.Connector.empty( numel( ch ), 0 );
            for i = 1:numel( ch )
                conn( i ) = systemcomposer.internal.getWrapperForImpl( ch( i ) );
            end
        end

        function parent = get.Parent( this )
            parent = systemcomposer.arch.Component.empty;
            if ~isempty( this.ElementImpl.getParentComponent(  ) )
                parentImpl = this.ElementImpl.getParentComponent(  );
                if isa( parentImpl, 'systemcomposer.architecture.model.design.VariantComponent' )
                    parent = systemcomposer.internal.getWrapperForImpl( parentImpl, 'systemcomposer.arch.VariantComponent' );
                else
                    parent = systemcomposer.internal.getWrapperForImpl( parentImpl, 'systemcomposer.arch.Component' );
                end

            end
        end

        function n = get.AliasName( this )
            impl = this.getImpl(  );
            n = impl.getAliasName(  );
        end

        function set.AliasName( this, val )
            impl = this.getImpl(  );
            if this.isRootLevel(  )
                impl.setAliasName( val );
            end
        end
    end

    methods
        cList = addComponent( this, cNameArray, stereotype, varargin );
        cVarList = addVariantComponent( this, cNameArray, varargin );
        pList = addPort( this, portNames, portTypes, stereotype );
        cn = connect( this, src, dst, varargin );
        applyStereotype( this, stereotype );
        iterate( this, iterType, iterFunc, varargin );
        batchApplyStereotype( this, varargin );
        pu = addParameter( this, name, varargin );

        function instance = instantiate( this, propertySets, name, varargin )


            if isempty( this.Parent )
                instance = systemcomposer.analysis.ArchitectureInstance.instantiate(  ...
                    this.SimulinkModelHandle, this.ElementImpl, propertySets, name, varargin{ : } );
            else
                error( 'systemcomposer:analysis:invalidInstantiate',  ...
                    message( 'SystemArchitecture:Analysis:InvalidInstantiationLocation' ).getString );
            end
        end

        function applyProfile( obj, prof )

            if isempty( obj.Parent )
                obj.getImpl.p_Model.addProfile( prof );
            else
                error( 'systemcomposer:API:ApplyProfileOnlyForRootArch', message(  ...
                    'SystemArchitecture:API:ApplyProfileOnlyForRootArch' ).getString );
            end
        end
        function removeProfile( obj, prof )

            if isempty( obj.Parent )
                obj.getImpl.p_Model.removeProfile( prof );
            else
                error( 'systemcomposer:API:ApplyProfileOnlyForRootArch', message(  ...
                    'SystemArchitecture:API:ApplyProfileOnlyForRootArch' ).getString );
            end
        end
        function num = getNumberOfInPorts( obj )

            num = obj.getImpl.getNumberOfInPorts;
        end
        function num = getNumberOfOutPorts( obj )

            num = obj.getImpl.getNumberOfOutPorts;
        end

        function prmNames = getParameterNames( this )
            prmNames = string( this.ElementImpl.getParameterNames(  ) );
        end

        function [ value, unit, isDefault ] = getParameterValue( this, paramFQN )
            valStruct = this.ElementImpl.getParamVal( paramFQN );
            value = valStruct.expression;
            unit = valStruct.units;
            isDefault = this.getImpl.isParamValDefault( paramFQN );
        end

        function setParameterValue( this, paramFQN, value, unit )

            arguments
                this{ mustBeA( this, 'systemcomposer.arch.Architecture' ) }
                paramFQN{ mustBeTextScalar }
                value{ mustBeTextScalar }
                unit{ mustBeTextScalar } = ''
            end

            compPromotedFrom = this.ElementImpl.getComponentPromotedFrom( paramFQN );
            if ~isempty( compPromotedFrom )
                compWrapper = systemcomposer.internal.getWrapperForImpl( compPromotedFrom );
                paramName = this.ElementImpl.getRelativeParameterFQN( compPromotedFrom, paramFQN );
                compWrapper.setParameterValue( paramName, value, unit );
            else


                if isempty( this.Parent )
                    mWksp = get_param( this.Name, 'ModelWorkspace' );
                    if mWksp.hasVariable( paramFQN )
                        modelArg = mWksp.getVariable( paramFQN );
                        if isa( modelArg, 'Simulink.Parameter' )
                            modelArg.Value = eval( value );
                            if nargin > 3
                                modelArg.Unit = unit;
                            end
                        else
                            dtype = class( modelArg );
                            valStr = sprintf( '%s(', '%d', ')', dtype, value );
                            mWksp.assignin( paramFQN, valStr );
                        end
                    end
                else
                    mask = get_param( this.SimulinkHandle, 'MaskObject' );
                    mp = mask.getParameter( paramFQN );
                    mp.DefaultValue = value;
                    if nargin > 3
                        unitVal = Simulink.Mask.Unit;
                        unitVal.BaseUnit = unit;
                        mp.Unit = unitVal;
                    end
                end

            end
        end

        function setUnit( this, paramFQN, unit )
            compPromotedFrom = this.ElementImpl.getComponentPromotedFrom( paramFQN );



            if isempty( compPromotedFrom )


                if isempty( this.Parent )
                    mWksp = get_param( this.Name, 'ModelWorkspace' );
                    if mWksp.hasVariable( paramFQN )
                        modelArg = mWksp.getVariable( paramFQN );
                        if isa( modelArg, 'Simulink.Parameter' )
                            modelArg.Unit = unit;
                        end
                    end
                end
            end
        end

        function resetParameterToDefault( this, paramFQN )
            compPromotedFrom = this.ElementImpl.getComponentPromotedFrom( paramFQN );
            if ~isempty( compPromotedFrom )
                compWrapper = systemcomposer.internal.getWrapperForImpl( compPromotedFrom );
                compWrapper.resetParameterToDefault( paramFQN );
            end
        end

        function params = get.Parameters( this )
            paramNames = this.getParameterNames;
            params = systemcomposer.arch.Parameter.empty( numel( paramNames ), 0 );
            for i = 1:numel( paramNames )
                params( i ) = systemcomposer.arch.Parameter.wrapper( this, paramNames( i ) );
            end
        end

        function param = getParameter( this, name )
            paramNames = this.getParameterNames;
            param = systemcomposer.arch.Parameter.empty;
            if any( ismember( paramNames, string( name ) ) )
                param = systemcomposer.arch.Parameter.wrapper( this, name );
            end
        end

        [ value, unit ] = getEvaluatedParameterValue( this, paramFQN )
    end

    methods ( Access = private )
        comp = getComponentFromName( this, compName );
        [ pArch, comp ] = detectHierarchyFromPath( this, compFullPath );
        comp = createComponent( this, blkName, parentList, compList );
        comp = checkAndCreateComponent( this, blkName );

        function addFunctionProp( this )
            funcProp = this.addprop( 'Functions' );
            funcProp.SetAccess = 'immutable';
            funcProp.Dependent = true;
            funcProp.GetMethod = @get_Functions;
        end

        function funcs = get_Functions( this )
            funcImpls =  ...
                this.getImpl(  ).getTrait( systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass ).getFunctionsOfType(  ...
                systemcomposer.architecture.model.swarch.FunctionType.OSFunction );


            [ ~, idxs ] = sort( [ funcImpls.executionOrder ] );
            funcImpls = funcImpls( idxs );
            funcs = arrayfun( @systemcomposer.internal.getWrapperForImpl, funcImpls );
            if isempty( funcs )
                funcs = systemcomposer.arch.Function.empty;
            end
        end

        function tf = isRootLevel( this )
            tf = ( this == this.Model.Architecture );
        end

        performExposeOrUnexposeOfParameter( this, varargin );
    end

end

function b = musBeAValidArchitecture( this )
b = isa( this, 'systemcomposer.arch.Architecture' );
isAutosarModel = Simulink.internal.isArchitectureModel( this.SimulinkModelHandle, 'AUTOSARArchitecture' );
if b
    if ~isempty( this.Parent )
        if this.Parent.IsAdapterComponent
            msgId = 'SystemArchitecture:Parameter:CannotDefineOnAdapters';
            throwAsCaller( MException( msgId, DAStudio.message( msgId ) ) );
        elseif isAutosarModel && autosar.bsw.ServiceComponent.isBswServiceComponent( this.SimulinkHandle )
            msgId = 'SystemArchitecture:Parameter:CannotDefineAUTOSARServiceComponents';
            throwAsCaller( MException( msgId, DAStudio.message( msgId ) ) );
        end
    end
else
    msgId = 'SystemArchitecture:API:ArchitectureInvalidInput';
    throwAsCaller( MException( msgId, DAStudio.message( msgId ) ) );
end
end

