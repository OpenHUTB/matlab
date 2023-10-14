classdef ( Sealed )ParamNodeAdapter < coderapp.internal.config.runtime.ControllableNodeAdapter

    properties ( Constant )
        NodeType coderapp.internal.config.runtime.NodeType = coderapp.internal.config.runtime.NodeType.Param
    end

    properties ( SetAccess = private )
        Dependencies coderapp.internal.config.runtime.ReferableNodeAdapter
    end

    properties ( Dependent, Hidden, SetAccess = immutable )
        ReferableValue
        ExportedValue
        ScriptValue
        ScriptCode
    end

    properties ( Dependent, SetAccess = immutable )
        Transient
        Internal
        Derived
    end

    properties ( Dependent, SetAccess = private )
        Awake
        DefaultValue
        UserModified
    end

    properties ( GetAccess = private, SetAccess = immutable )
        ParamTypeController
    end

    properties ( Access = private )
        ForcePropagate = false
        InvokingControllers = false
        ModifiedByControllers = false
        ValidatingControllers
        ImportingControllers
        ExportingControllers
        CodingControllers
        PostSetControllers
    end

    properties ( Dependent, Access = private )
        CachedExportedValue
        HasCachedExportedValue
        CachedCode
        HasCachedCode
    end

    methods
        function this = ParamNodeAdapter( paramDef, paramType, paramTypeController, schemaIdx )
            arguments
                paramDef( 1, 1 )coderapp.internal.config.schema.ParamDef
                paramType( 1, 1 )coderapp.internal.config.AbstractParamType
                paramTypeController
                schemaIdx( 1, 1 )double
            end

            this@coderapp.internal.config.runtime.ControllableNodeAdapter( paramDef, schemaIdx );
            this.DataObjectStrategy = paramType;
            this.ParamTypeController = paramTypeController;
        end

        function adjusted = validateParamValue( this, value )
            adjusted = this.DataObjectStrategy.validate( value, this.DataObject );
            for controller = this.ValidatingControllers
                adjusted = controller.validate( adjusted );
            end
        end

        function changed = importValue( this, value, external )
            arguments
                this( 1, 1 )
                value
                external( 1, 1 ){ mustBeNumericOrLogical( external ) } = true
            end
            changed = this.doSetValue( value, External = external, Import = true );
        end

        function changed = importAttr( this, attr, attrValue, external )
            if nargin == 2
                attrValue = attr;
                attr = 'Value';
            elseif isempty( attr )
                attr = 'Value';
            end
            if strcmpi( attr, 'Value' )
                changed = this.importValue( attrValue, nargin < 4 || external );
            elseif strcmpi( attr, 'DefaultValue' )
                changed = this.setDefaultValue( attrValue, true );
            else
                changed = importAttr@coderapp.internal.config.runtime.ControllableNodeAdapter( this, attr, attrValue );
                if this.InvokingControllers
                    this.ModifiedByControllers = this.ModifiedByControllers || changed;
                end
                if changed && strcmp( attr, 'Visible' ) && ~this.DataObject.Visible
                    this.EffectiveVisible = false;
                end
            end
        end

        function changed = setValue( this, value, external )
            arguments
                this( 1, 1 )
                value = this.DefaultValue
                external( 1, 1 )logical = true
            end
            changed = this.doSetValue( value, External = external, Import = false );
        end

        function changed = setAttr( this, attr, attrValue, external )
            if nargin == 2
                attrValue = attr;
                attr = 'Value';
            elseif isempty( attr )
                attr = 'Value';
            end
            if strcmp( attr, 'Value' )
                changed = this.setValue( attrValue, nargin < 4 || external );
            elseif strcmp( attr, 'DefaultValue' )
                changed = this.setDefaultValue( attrValue );
            else
                changed = setAttr@coderapp.internal.config.runtime.ControllableNodeAdapter( this, attr, attrValue );
                if this.InvokingControllers
                    this.ModifiedByControllers = this.ModifiedByControllers || changed;
                end
                if changed && strcmp( attr, 'Visible' ) && ~this.DataObject.Visible
                    this.EffectiveVisible = false;
                end
            end
        end

        function changed = setDefaultValue( this, value, import )
            arguments
                this
                value
                import = false
            end

            logCleanup = this.Logger.debug( 'Setting default value for "%s"', this.Key );%#ok<NASGU>
            if import
                value = this.invokeImporters( value );
            end
            defaultChanged = ~isequal( this.DefaultValue, value );
            if defaultChanged
                this.DefaultValue = value;
                this.Logger.debug( 'Default value changed' );
            else
                this.Logger.trace( 'Default value unchanged' );
            end
            changed = false;
            if ~this.UserModified
                changed = this.setValue( value, false );
            end
            this.UserModified = ~isequal( this.DefaultValue, this.ReferableValue );
        end

        function attrValue = getAttr( this, attr )
            arguments
                this
                attr char = 'Value';
            end
            if strcmp( attr, 'DefaultValue' )
                attrValue = this.DefaultValue;
            else
                attrValue = getAttr@coderapp.internal.config.runtime.ControllableNodeAdapter( this, attr );
            end
        end

        function exported = exportAttr( this, attr )
            arguments
                this
                attr char = 'Value';
            end
            isValue = strcmp( attr, 'Value' );
            if isValue && this.HasCachedExportedValue
                exported = this.CachedExportedValue;
            else
                exported = exportAttr@coderapp.internal.config.runtime.ControllableNodeAdapter( this, attr );
                if isValue
                    for controller = this.ExportingControllers
                        exported = controller.export( exported );
                    end
                    this.CachedExportedValue = exported;
                    this.HasCachedExportedValue = true;
                end
            end
        end

        function prodConfig = getProductionConfig( this, key )
            arguments
                this
                key{ mustBeTextScalar( key ) }
            end
            prodRef = this.SchemaDef.ProductionRefs.getByKey( key );
            if ~isempty( prodRef )
                prodConfig = prodRef.ProductionConfig;
            else
                prodConfig = [  ];
            end
        end

        function attrs = getAttributeNames( this )
            attrs = getAttributeNames@coderapp.internal.config.runtime.ControllableNodeAdapter( this );
            attrs{ end  + 1 } = 'DefaultValue';
        end

        function value = get.ReferableValue( this )
            value = this.getAttr( 'Value' );
        end

        function value = get.ExportedValue( this )
            if this.HasCachedExportedValue
                value = this.CachedExportedValue;
            else
                value = this.exportAttr( 'Value' );
            end
        end

        function scriptValue = get.ScriptValue( this )
            if ~this.HasCachedCode
                this.updateScriptCode(  );
            end
            scriptValue = this.CachedCode;
        end

        function code = get.ScriptCode( this )
            scriptValue = this.ScriptValue;
            if isobject( scriptValue )
                code = scriptValue.build( this.Configuration.ScriptOptions );
            else
                code = scriptValue;
            end
        end

        function userModified = get.UserModified( this )
            userModified = this.StateObject.UserModified;
        end

        function set.UserModified( this, modified )
            prev = this.StateObject.UserModified;
            if modified
                this.Configuration.ConfigStoreAdapter.setValue( this, this.ReferableValue );
            elseif prev
                this.Configuration.ConfigStoreAdapter.removeValue( this );
            end
            if modified ~= prev
                this.StateObject.UserModified = modified;
                this.Logger.debug( 'UserModified set to %g', modified );
            end
        end

        function transient = get.Transient( this )
            transient = this.StateObject.Transient;
        end

        function internal = get.Internal( this )
            internal = this.StateObject.Internal;
        end

        function derived = get.Derived( this )
            derived = this.StateObject.Derived;
        end

        function awake = get.Awake( this )
            awake = this.StateObject.Awake;
        end

        function set.Awake( this, awake )
            this.StateObject.Awake = awake;
        end

        function set.DefaultValue( this, value )
            this.StateObject.Default.Value = value;
        end

        function value = get.DefaultValue( this )
            value = this.StateObject.Default.Value;
        end

        function value = get.CachedExportedValue( this )
            value = this.StateObject.CachedExportedValue;
        end

        function set.CachedExportedValue( this, value )
            this.StateObject.CachedExportedValue = value;
        end

        function has = get.HasCachedExportedValue( this )
            has = this.StateObject.HasCachedExportedValue;
        end

        function set.HasCachedExportedValue( this, has )
            this.StateObject.HasCachedExportedValue = has;
        end

        function code = get.CachedCode( this )
            code = this.StateObject.CachedCode;
        end

        function set.CachedCode( this, code )
            this.StateObject.CachedCode = code;
        end

        function has = get.HasCachedCode( this )
            has = this.StateObject.HasCachedCode;
        end

        function set.HasCachedCode( this, has )
            this.StateObject.HasCachedCode = has;
        end
    end

    methods ( Access = { ?coderapp.internal.config.runtime.NodeAdapter, ?coderapp.internal.config.Configuration,  ...
            ?coderapp.internal.config.runtime.ConfigStoreAdapter } )
        function initNode( this, configuration )
            paramDef = this.SchemaDef;
            if ~isempty( paramDef.Requires )
                this.Dependencies = configuration.getNodes( [ paramDef.Requires.Ordinal ] );
            end
            this.DefaultValue = this.DataObject.Value;
            initNode@coderapp.internal.config.runtime.ControllableNodeAdapter( this, configuration );

            controllers = this.Controllers;
            this.ValidatingControllers = controllers( [ controllers.CanValidate ] );
            this.ImportingControllers = controllers( [ controllers.CanImport ] );
            this.ExportingControllers = controllers( [ controllers.CanExport ] );
            this.CodingControllers = controllers( [ controllers.CanToCode ] );
            this.PostSetControllers = controllers( [ controllers.CanPostSet ] );
        end

        function resetNode( this )
            resetNode@coderapp.internal.config.runtime.ControllableNodeAdapter( this );
            this.HasCachedExportedValue = false;
            this.CachedExportedValue = [  ];
            this.HasCachedCode = false;
            this.CachedCode = '';
        end

        function changed = resetParam( this, external )
            arguments
                this
                external = false
            end

            logCleanup = this.Logger.debug( 'Resetting param "%s" (External=%g)', this.Key, external );%#ok<NASGU>
            changed = this.doSetValue( this.DefaultValue,  ...
                External = external,  ...
                Import = false,  ...
                Validate = false,  ...
                IgnoreEnabled = true );
        end

        function updateNode( this, triggers )
            if ~this.InvokingControllers
                this.Awake = true;
                cleanup = this.revalidateOnCleanup(  );%#ok<NASGU>
                updateNode@coderapp.internal.config.runtime.ControllableNodeAdapter( this, triggers );
            end
        end

        function activateNode( this )
            cleanup = this.revalidateOnCleanup(  );%#ok<NASGU>


            activateNode@coderapp.internal.config.runtime.ControllableNodeAdapter( this );

        end

        function choices = getTabCompletions( this, input, isImport )
            arguments
                this( 1, 1 )
                input{ mustBeTextScalar( input ) } = ''
                isImport( 1, 1 )logical = false
            end
            if ~isImport || isempty( this.ImportingControllers )
                choices = this.DataObjectStrategy.getTabCompletions( input, this.DataObject );
                if ~iscell( choices )
                    if isstring( choices )
                        choices = cellstr( choices );
                    else
                        choices = num2cell( choices );
                    end
                end
            else
                choices = {  };
            end
        end
    end

    methods ( Access = ?coderapp.internal.config.runtime.ConfigStoreAdapter )
        function dataObj = newValueObject( this, value )
            arguments
                this
                value = this.ReferableValue
            end

            dataObj = this.DataObjectStrategy.newDataObject( this.Configuration.RuntimeModel );
            dataObj.Value = value;
        end
    end

    methods ( Access = protected )
        function extraControllers = getExtraControllers( this )
            extraControllers = this.ParamTypeController;
        end
    end

    methods ( Access = { ?coderapp.internal.config.runtime.ConfigStoreAdapter, ?coderapp.internal.config.AbstractController } )
        function changed = doSetValue( this, value, opts )
            arguments
                this
                value
                opts.External = true
                opts.Import = false
                opts.Validate = [  ]
                opts.IgnoreEnabled = false
            end

            external = opts.External;
            import = opts.Import;
            configImporting = ~isempty( this.Configuration.ImportOptions );

            if ~isempty( opts.Validate )
                shouldValidate = opts.Validate;
            elseif ~configImporting || ~import || ~external
                shouldValidate = external;
            else
                shouldValidate = this.Configuration.ImportOptions.validate;
            end

            logCleanup = this.Logger.trace( @(  )sprintf(  ...
                'Entering doSetValue for "%s" (External=%g, ParamImport=%g, ProductionImport=%g, Validate=%g)',  ...
                this.Key, external, import, configImporting, shouldValidate ) );%#ok<NASGU>

            if external && ~this.DataObject.Enabled && ~configImporting &&  ...
                    ~this.InvokingControllers && ~opts.IgnoreEnabled
                error( 'Cannot modify disabled param "%s"', this.Key );
            end
            if import
                value = this.invokeImporters( value );
            end
            if shouldValidate
                if ~this.Awake
                    this.updateNode( this.Dependencies );
                end
                value = this.validateParamValue( value );
            end
            changed = this.doSetAttr( 'Value', value, false );
            if changed || this.ForcePropagate
                this.HasCachedExportedValue = false;
                this.HasCachedCode = false;
                this.Propagate = true;
                this.updateSuccessorDepViews(  );
            end
            if changed
                this.Configuration.reportChange( this, 'Value', external );
            end
            defaultChanged = false;
            if external
                this.UserModified = ~isequal( value, this.DefaultValue );
            else
                defaultChanged = ~isequal( this.DefaultValue, value );
                this.DefaultValue = value;
                this.UserModified = false;
                if this.InvokingControllers
                    this.ModifiedByControllers = this.ModifiedByControllers || changed;
                end
            end
            if changed || defaultChanged
                this.postSetNode(  );
            end
        end
    end

    methods ( Access = private )
        function value = invokeImporters( this, value )
            for controller = this.ImportingControllers
                value = controller.import( value );
            end
            value = this.DataObjectStrategy.import( 'Value', value );
        end

        function postSetNode( this )
            if ~this.InvokingControllers && ~isempty( this.PostSetControllers )
                cleanup = this.revalidateOnCleanup(  );%#ok<NASGU>
                this.invokeControllersVoid( 'postSet' );
            end
        end

        function cleanup = revalidateOnCleanup( this )
            this.ModifiedByControllers = false;
            this.InvokingControllers = true;
            if this.UserModified
                cleanup = onCleanup( @(  )this.revalidate(  ) );
            else
                cleanup = onCleanup( @(  )this.clearControllerFlag(  ) );
            end
        end

        function revalidate( this )
            this.clearControllerFlag(  );
            if ~this.ModifiedByControllers
                return
            end
            this.ModifiedByControllers = false;
            if ~this.UserModified
                return
            end


            try
                this.validateParamValue( this.getAttr( 'Value' ) );
            catch
                this.resetParam(  );
            end
        end

        function clearControllerFlag( this )
            this.InvokingControllers = false;
        end

        function updateScriptCode( this )
            logCleanup = this.Logger.debug( 'Updating script code snippet' );%#ok<NASGU>
            code = '';
            codingControllers = this.CodingControllers;

            if ~isempty( codingControllers )
                value = this.ReferableValue;
                for controller = codingControllers
                    code = controller.toCode( value );
                    if ~isempty( code )
                        this.Logger.trace( 'Code provided by controller "%s"', controller.Id );
                        break
                    end
                end
            else
                code = this.DataObjectStrategy.toCode( this.ExportedValue );
            end

            if isstring( code )
                code = char( code );
            end
            this.CachedCode = code;
            this.HasCachedCode = true;
            this.Logger.debug( 'Code changed to: %s', code );
        end
    end
end


