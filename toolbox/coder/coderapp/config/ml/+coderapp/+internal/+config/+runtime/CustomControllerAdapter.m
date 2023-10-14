classdef ( Sealed )CustomControllerAdapter < coderapp.internal.config.runtime.ControllerAdapter

    properties ( Dependent, SetAccess = immutable )
        Id
    end

    properties ( GetAccess = private, SetAccess = immutable )
        Delegate
        ControllerRef coderapp.internal.config.schema.ControllerRef
    end

    properties ( Access = private )
        Node coderapp.internal.config.runtime.NodeAdapter
        ValidateMethod
        ImportMethod
        ExportMethod
        ToCodeMethod
        UpdateMethod
        PostSetMethod
        InitializeMethod
    end

    methods ( Access = { ?coderapp.internal.config.runtime.ControllerAdapter,  ...
            ?coderapp.internal.config.runtime.NodeAdapter } )
        function this = CustomControllerAdapter( controller, controllerRef )
            arguments
                controller coderapp.internal.config.AbstractController
                controllerRef coderapp.internal.config.schema.ControllerRef
            end
            this.Delegate = controller;
            this.ControllerRef = controllerRef;
        end

        function initAdapter( this, node )
            this.Node = node;
            this.Logger = node.Logger;

            [ this.ValidateMethod, this.InitializeMethod, this.UpdateMethod, this.PostSetMethod,  ...
                this.ImportMethod, this.ExportMethod, this.ToCodeMethod ] = preprareHandlers( node.Dependencies,  ...
                this.ControllerRef.Validate, this.ControllerRef.Initialize,  ...
                this.ControllerRef.Update, this.ControllerRef.PostSet,  ...
                this.ControllerRef.Import, this.ControllerRef.Export,  ...
                this.ControllerRef.ToCode );

            this.CanValidate = ~isempty( this.ValidateMethod );
            this.CanImport = ~isempty( this.ImportMethod );
            this.CanExport = ~isempty( this.ExportMethod );
            this.CanToCode = ~isempty( this.ToCodeMethod );
            this.CanPostSet = ~isempty( this.PostSetMethod );
        end

        function value = validate( this, value )
            if ~isempty( this.ValidateMethod )
                value = this.invoke( 'validate', this.ValidateMethod, { value } );
            end
        end

        function value = import( this, value )
            if ~isempty( this.ImportMethod )
                value = this.invoke( 'import', this.ImportMethod, { value } );
            end
        end

        function value = export( this, value )
            if ~isempty( this.ExportMethod )
                value = this.invoke( 'export', this.ExportMethod, { value } );
            end
        end

        function code = toCode( this, value )
            if ~isempty( this.ToCodeMethod )
                code = this.invoke( 'toCode', this.ToCodeMethod, { value } );
            else
                code = '[]';
            end
        end

        function initialize( this )
            if ~isempty( this.InitializeMethod )
                this.invoke( 'initialize', this.InitializeMethod );
            else
                this.invoke( 'initialize', this.UpdateMethod );
            end
        end

        function postSet( this )
            this.invoke( 'postSet', this.PostSetMethod );
        end

        function update( this )
            this.invoke( 'update', this.UpdateMethod );
        end
    end

    methods
        function id = get.Id( this )
            id = this.ControllerRef.Id;
        end
    end

    methods ( Access = private )
        function varargout = invoke( this, hookName, methodInfo, explicitArgs )
            arguments
                this
                hookName
                methodInfo
                explicitArgs = [  ]
            end

            if isempty( methodInfo )
                varargout = cell( 1, nargout );
                return
            end
            logCleanup = this.Logger.trace( 'Invoking custom controller (%s)', hookName );%#ok<NASGU>

            ref = methodInfo.ref;
            if iscell( explicitArgs )
                args = explicitArgs;
            elseif ref.UseConstantArgs
                args = ref.ConstantArgs;
            else
                args = { methodInfo.dynamicArgs.ReferableValue };
            end

            cleanup = this.Delegate.attachToNode( this.Node );%#ok<NASGU>
            this.Logger.debug( @(  )this.getInvocationLogText( ref.Method, args ) );
            try
                if nargout > 0
                    [ varargout{ 1:nargout } ] = this.Delegate.( ref.Method )( args{ : } );
                else
                    this.Delegate.( ref.Method )( args{ : } );
                end
            catch me
                diag = sprintf( 'Error invoking controller method: node=%s, hook=%s, controller=%s, method=%s',  ...
                    this.Node.Key, hookName, this.ControllerRef.Id, ref.Method );
                this.Logger.error( diag );
                me.throw(  );
            end
        end

        function str = getInvocationLogText( this, methodName, args )
            controllerClass = class( this.Delegate );
            for i = 1:numel( args )
                arg = args{ i };
                if strcmp( class( arg ), controllerClass )
                    args{ i } = 'this';
                else
                    args{ i } = coderapp.internal.value.valueToExpression( arg );
                    if isempty( args{ i } )
                        args{ i } = class( arg );
                    end
                end
            end
            argStr = strjoin( args, ', ' );

            if feature( 'hotlinks' )
                delegateStr = sprintf( '<a href="matlab: edit %s/%s">%s/%s</a>',  ...
                    controllerClass, methodName, controllerClass, methodName );
            else
                delegateStr = [ controllerClass, '/', methodName ];
            end
            str = sprintf( '%s(%s)', delegateStr, argStr );
        end
    end
end


function varargout = preprareHandlers( depNodes, varargin )
refs = [ varargin{ : } ];
varargout = cell( 1, numel( varargin ) );
outIdx = find( ~cellfun( 'isempty', varargin ) );
for i = 1:numel( refs )
    ref = refs( i );
    methodDesc.ref = ref;
    if ~ref.UseConstantArgs
        methodDesc.dynamicArgs = depNodes( 1:min( numel( depNodes ), ref.DynamicArgCount ) );
    end
    varargout{ outIdx( i ) } = methodDesc;
end
end

