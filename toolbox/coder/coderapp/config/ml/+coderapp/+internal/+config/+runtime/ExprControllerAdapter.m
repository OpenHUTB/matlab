classdef ( Sealed )ExprControllerAdapter < coderapp.internal.config.runtime.ControllerAdapter

    properties ( SetAccess = immutable )
        Id
    end

    properties ( GetAccess = private, SetAccess = immutable )
        ExprDefs coderapp.internal.config.schema.EvalDef
    end

    properties ( Access = private )
        Node coderapp.internal.config.runtime.NodeAdapter
        ConstValues cell = {  }
    end

    methods ( Access = { ?coderapp.internal.config.runtime.ControllerAdapter,  ...
            ?coderapp.internal.config.runtime.NodeAdapter } )
        function this = ExprControllerAdapter( schemaDefs )
            arguments
                schemaDefs coderapp.internal.config.schema.EvalDef
            end
            this.ExprDefs = schemaDefs;
        end

        function initAdapter( this, node )
            this.Node = node;
            this.Logger = node.Logger;
        end

        function initialize( this )
            this.execute(  );
        end

        function update( this )
            this.execute(  );
        end

        function postSet( this )
            this.execute(  );
        end
    end

    methods ( Access = private )
        function execute( this )
            logCleanup = this.Logger.trace( 'Executing eval-based controller' );%#ok<NASGU>
            specialCaseValue = this.Node.NodeType == "Param";
            constVals = this.ConstValues;
            first = isempty( constVals );
            exprs = this.ExprDefs;

            for i = 1:numel( exprs )
                expr = exprs( i );
                code = expr.Code;
                innerLogCleanup = this.Logger.debug( 'Processing expression: %s', code );%#ok<NASGU>
                if expr.Constant
                    if first
                        this.Logger.debug( 'Initializing constant value' );
                        value = this.evalExpr( code );
                        constVals{ i } = value;
                    else
                        value = constVals{ i };
                        this.Logger.debug( @(  )'Reusing stored constant value for expression: %s',  ...
                            coderapp.internal.value.valueToExpression( value ) );
                    end
                else
                    value = this.evalExpr( code );
                end
                if specialCaseValue && strcmp( expr.Attribute, 'Value' )


                    this.Node.setDefaultValue( value, true );
                else
                    this.Node.importAttr( expr.Attribute, value );
                end
                innerLogCleanup = [  ];%#ok<NASGU>
            end
            if first
                this.ConstValues = constVals;
            end
        end

        function result = evalExpr( this, expr )
            node = this.Node;
            depView = node.getDependencyView(  );
            keys = [ node.Key;fieldnames( depView ) ];
            depVals = struct2cell( depView );
            if isempty( depVals )
                depVals = { node.ReferableValue };
            else
                depVals = [ { node.ReferableValue };depVals ];
            end
            result = coderapp.internal.config.evalScopedExpr( expr, keys, depVals,  ...
                node.Configuration.Debug );
        end
    end
end


