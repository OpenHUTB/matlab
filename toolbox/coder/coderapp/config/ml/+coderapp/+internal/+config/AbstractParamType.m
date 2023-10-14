classdef ( Abstract )AbstractParamType < coderapp.internal.config.UserVisibleDataObjectStrategy & matlab.mixin.Heterogeneous




    properties ( SetAccess = immutable )
        Name char{ mustBeValidParamTypeName( Name ) }
        IsArray logical
        ImportsValue logical
        ExportsValue logical
    end

    properties ( GetAccess = private, SetAccess = immutable )
        Handlers struct
        ConstrainsLength logical
    end

    methods
        function this = AbstractParamType( name, dataObjectClass, varargin )
            this@coderapp.internal.config.UserVisibleDataObjectStrategy( dataObjectClass );
            this.Name = name;

            [ this.IsArray, this.ConstrainsLength ] = validateDataObjectClass( this.MfzMetaClass );

            attrs = coderapp.internal.config.ParamAttribute.empty(  );
            for i = 1:numel( varargin )
                arg = varargin{ i };
                if ~isvector( arg ) || ( ~iscell( arg ) && ~isa( arg, 'coderapp.internal.config.ParamAttribute' ) )
                    error( 'Arguments must be cell arguments compatible with Attribute or Attribute instances' );
                end
                if iscell( arg )
                    arg = coderapp.internal.config.ParamAttribute( arg{ : } );
                end
                attrs( end  + 1:end  + numel( arg ) ) = arg;
            end

            validateDataObjectProps( this.MfzMetaClass, attrs );
            this.Handlers = validateAttributeMethods( metaclass( this ), this.MfzMetaClass, attrs );
            this.ImportsValue = ~isempty( this.Handlers.Value.FromCanonical );
            this.ExportsValue = ~isempty( this.Handlers.Value.ToCanonical );
        end

        function controllerAdapter = createController( ~ )



            controllerAdapter = [  ];
        end

        function choices = getTabCompletions( ~, input, dataObj )%#ok<INUSD>
            choices = {  };
        end
    end

    methods
        function adjustedValue = validate( this, value, dataObj )
            arguments
                this
                value
                dataObj = [  ]
            end
            adjustedValue = this.delegate( 'Value', 'Validator', value, dataObj );
        end

        function imported = import( this, attr, value )
            if strcmp( attr, 'Value' )
                imported = this.importValue( value );
            else
                imported = this.delegate( attr, 'FromCanonical', value );
            end
        end

        function exported = export( this, attr, value )
            if strcmp( attr, 'Value' )
                exported = this.exportValue( value );
            else
                exported = this.delegate( attr, 'ToCanonical', value );
            end
        end

        function varargout = fromSchema( this, attr, value, varargin )
            if strcmp( attr, 'Value' )
                varargout{ 1 } = this.valueFromSchema( value );
            else
                [ varargout{ 1:nargout } ] = this.delegate( attr, 'FromSchema', value, varargin{ : } );
            end
        end

        function yes = isAttribute( this, attr )
            yes = isfield( this.Handlers, attr );
        end

        function varargout = nameFromSchema( this, varargin )
            [ varargout{ 1:nargout } ] = this.schemaImportPossibleMessage( varargin{ : }, 'Name' );
        end

        function varargout = descriptionFromSchema( this, varargin )
            [ varargout{ 1:nargout } ] = this.schemaImportPossibleMessage( varargin{ : }, 'Description' );
        end

        function varargout = regexDescriptionFromSchema( this, varargin )
            [ varargout{ 1:nargout } ] = this.schemaImportPossibleMessage( varargin{ : }, 'RegexDescription' );
        end
    end

    methods ( Access = protected )
        function imported = importValue( this, value )
            imported = this.delegate( 'Value', 'FromCanonical', value );
        end

        function exported = exportValue( this, value )
            exported = this.delegate( 'Value', 'ToCanonical', value );
        end

        function value = valueFromSchema( this, value )
            value = this.delegate( 'Value', 'FromSchema', value );
        end
    end

    methods ( Abstract )
        code = toCode( this, value )

        str = toString( this, value )
    end

    methods ( Sealed, Access = protected )
        function attrs = doGetAttributes( this )
            attrs = fieldnames( this.Handlers );
        end

        function validateArraySize( this, value, dataObj )
            if isempty( dataObj )
                return
            end
            if this.IsArray && this.ConstrainsLength

                assert( isempty( dataObj.MinLength ) || numel( value ) >= dataObj.MinLength );
                assert( isempty( dataObj.MaxLength ) || numel( value ) <= dataObj.MaxLength );
            end
        end
    end


    methods ( Static, Sealed, Access = protected )
        function varargout = identity( value, varargin )
            varargout{ 1 } = value;
            if nargout > 1
                varargout{ 2 } = [  ];
            end
        end

        function str = defaultstring( value )%#ok<INUSD>
            [ ~, str ] = evalc( 'disp(value)' );
        end

        function code = defaultcode( value )
            code = mat2str( value );
        end

        function allowed = isAllowedValue( value, dataObj )
            allowed = true;
            if isempty( dataObj )
                return
            end
            enumerated = dataObj.AllowedValues;
            if isa( enumerated, 'handle' )
                if enumerated.Size == 0
                    return
                end
                enumerated = enumerated.toArray(  );
            elseif isempty( enumerated )
                return
            end
            if isa( value, 'handle' )
                value = value.toArray(  );
            end
            allowed = all( ismember( value, enumerated ) );
        end
    end

    methods ( Access = private )
        function varargout = delegate( this, attr, hookType, varargin )
            try
                handler = this.Handlers.( attr );
            catch
                error( '"%s" is not a valid attribute of %s', attr, this.Name );
            end
            handler = handler.( hookType );
            if isempty( handler )
                varargout = cell( 1, numel( varargin ) );
                varargout{ 1 } = varargin{ 1 };
                for i = 2:nargout
                    varargout{ i } = [  ];
                end
                return
            end
            if handler.static
                [ varargout{ 1:nargout } ] = handler.funcHandle( varargin{ : } );
            else
                [ varargout{ 1:nargout } ] = handler.funcHandle( this, varargin{ : } );
            end
        end
    end
end


function [ isArray, constrainsLength ] = validateDataObjectClass( doClass )
assert( ismember( 'coderapp.internal.config.data.ParamData',  ...
    [ doClass.qualifiedName;superclasses( doClass.qualifiedName ) ] ),  ...
    'DataObject implementation for params must extend coderapp.internal.config.data.store.ParamData' );
valDef = doClass.getPropertyByName( 'Value' );
assert( ~isempty( valDef ), 'Expected Value attribute to have been registered' );
assert( ismember( class( valDef.type ), { 'mf.zero.meta.DataType', 'mf.zero.meta.PrimitiveType' } ),  ...
    'Type of value property must be a MF0 primitive or value class (struct)' );
isArray = valDef.upper > 1 && valDef.isOrdered;
constrainsLength = isArray && ~isempty( doClass.getPropertyByName( 'MinLength' ) ) &&  ...
    ~isempty( doClass.getPropertyByName( 'MaxLength' ) );
end


function handlers = validateAttributeMethods( mc, smc, attrs )
attrs = mixinUnspecifiedProps( smc.qualifiedName, attrs, [
    coderapp.internal.config.ParamAttribute( 'Name',  ...
    'FromSchema', 'nameFromSchema' )
    coderapp.internal.config.ParamAttribute( 'Description',  ...
    'FromSchema', 'descriptionFromSchema' )
    coderapp.internal.config.ParamAttribute( 'Help',  ...
    'FromSchema', 'toDocRef', 'FromCanonical', 'toDocRef' )
    coderapp.internal.config.ParamAttribute( 'Refreshable' )
    ] );
methodProps = { 'Validator', 'FromSchema', 'FromCanonical', 'ToCanonical' };
valueOnlyProps = { 'ToString', 'ToCode' };
defaultAttr = coderapp.internal.config.ParamAttribute(  );
handlers = cell2struct( cell( numel( attrs ), numel( methodProps ) ), methodProps, 2 );

methods = mc.MethodList;
methods = methods( cellfun( 'isclass', { methods.Access }, 'char' ) );
methods = methods( ismember( { methods.Access }, { 'public', 'protected' } ) );
realNames = { methods.Name };

for i = 1:numel( attrs )
    attr = attrs( i );
    isValue = strcmp( attr.Name, 'Value' );
    for j = 1:numel( methodProps )
        methodProp = methodProps{ j };
        handlerName = attr.( methodProp );
        if isempty( handlerName )
            handlers( i ).( methodProp ) = [  ];
            continue
        end
        [ ~, idx ] = ismember( handlerName, realNames );
        if idx ~= 0
            method = methods( idx );
            if ~isValue && any( strcmp( methodProp, valueOnlyProps ) ) && ~strcmp( handlerName, defaultAttr.( methodProp ) )
                error( 'Only special "Value" attribute can specify a non-default "%s" delegate', methodProp );
            elseif strcmp( method.Name, 'delete' )
                error( 'delete cannot be used as an attribute method' );
            end
            handlers( i ).( methodProp ) = toMethodDesc( method );
        else
            error( 'No public or protected method named "%s" in class %s', handlerName, mc.Name );
        end
    end
end

handlers = cell2struct( reshape( num2cell( handlers ), [  ], 1 ), { attrs.Name }, 1 );
end


function validateDataObjectProps( smc, attrs )
if isempty( attrs )
    return
end

names = { attrs.Name };
if any( cellfun( 'isempty', names ) )
    error( 'Attribute names cannot be empty' );
end

cur = smc;
props = mf.zero.meta.Property.empty(  );
while ~isempty( cur )
    props( end  + 1:end  + cur.ownedAttributes.Size ) = cur.ownedAttributes.toArray(  );
    cur = cur.superclass;
end
props = props( [ props.isPublicAccessor ] & [ props.isPublicMutator ] );

found = ismember( names, { props.name } );
if any( strcmpi( names, 'DefaultValue' ) )
    error( 'DefaultValue is a reserved name' );
end
if ~all( found )
    error( 'Attributes should map by name to public DataObject class properties: %s', strjoin( names( ~found ), ', ' ) );
end
end


function expanded = mixinUnspecifiedProps( className, specified, mixins )
if ~isempty( specified )
    props = setdiff( properties( className ), { specified.Name } );
else
    props = properties( className );
end
[ ~, pIdx, mIdx ] = intersect( props, { mixins.Name } );
props( pIdx ) = [  ];
props = num2cell( props );
expanded = [ reshape( specified, 1, [  ] ), reshape( mixins( mIdx ), 1, [  ] ) ...
    , coderapp.internal.config.ParamAttribute( props{ : } ) ];
end


function method = toMethodDesc( mm )
method.static = mm.Static;

if mm.Static
    method.funcHandle = str2func( [ mm.DefiningClass.Name, '.', mm.Name ] );
else
    method.funcHandle = str2func( mm.Name );
end
end


function mustBeValidParamTypeName( name )
if ~isempty( name ) && isempty( regexp( name, '^\S+$', 'once' ) )
    error( 'Param type name "%s" contains whitespace', name );
end
end


