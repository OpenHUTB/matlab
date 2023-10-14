function [ parsed, mfzModel, referred ] = parse( raw, mfzModel, symbols )
arguments
    raw
    mfzModel mf.zero.Model = mf.zero.Model(  )
    symbols struct = struct( 'name', {  }, 'subroutine', {  }, 'type', {  } )
end

if ( nargin < 2 || isempty( mfzModel ) ) && nargout < 2
    error( 'If no MF0 model is provided, the caller must handle two outputs' );
end

byKeyword = coderapp.internal.config.expr.OpDefs.getKeywordStruct(  );
if nargin > 2
    symbolMap = containers.Map( { symbols.name }, num2cell( symbols ) );
    validateRefs = true;
else
    symbolMap = containers.Map(  );
    validateRefs = false;
end

trackReferred = nargout > 2;
if trackReferred
    referred = {  };
end

parsed = parseIt( raw );



    function result = parseIt( raw, parentOperator )
        if nargin < 2
            parentOperator = '';
        end
        if isstruct( raw )
            result = parseOperation( raw, parentOperator );
        elseif ischar( raw )
            if isempty( raw )
                error( 'Empty string not expected' );
            end
            switch raw( 1 )
                case { '''', '"' }
                    result = coderapp.internal.config.expr.StringConstant( mfzModel,  ...
                        struct( 'Value', raw( 2:end  - endsWith( raw, { '''', '"' } ) ) ) );
                otherwise
                    result = parseRef( raw, parentOperator );
            end
        elseif islogical( raw )
            result = coderapp.internal.config.expr.BooleanConstant( mfzModel, struct( 'Value', raw ) );
        elseif isnumeric( raw )
            result = coderapp.internal.config.expr.NumericConstant( mfzModel, struct( 'Value', raw ) );
        else
            error( 'Unsupported class: %s', class( raw ) );
        end
        result = rewrite( mfzModel, result, parentOperator );
    end


    function result = parseOperation( raw, ~ )
        if ~isstruct( raw ) || ~isscalar( raw )
            error( 'Expected a JSON object' );
        end

        opDef = [  ];
        args = {  };
        fields = fieldnames( raw );
        if numel( fields ) > 1
            warning( 'Multiple properties found where only one is expected' );
        end
        fIdx = 1;
        while fIdx <= numel( fields )
            if isfield( byKeyword, fields{ fIdx } )
                opDef = byKeyword.( fields{ fIdx } );
                args = raw.( fields{ fIdx } );
                break
            else
                fIdx = fIdx + 1;
            end
        end
        if isempty( opDef )
            error( 'Operation object must have a property naming a valid operator' );
        end

        if ~iscell( args )
            if ischar( args )
                args = { args };
            else
                args = num2cell( args );
            end
        end
        if opDef.Arity < 0
            if numel( args ) < ( abs( opDef.Arity ) - 1 )
                error( 'Expected at least %d arguments but found %d', opDef.Arity, numel( args ) );
            end
        elseif numel( args ) ~= opDef.Arity
            error( 'Expected %d arguments but found %d', opDef.Arity, numel( args ) );
        end

        for ai = 1:numel( args )
            args{ ai } = parseIt( args{ ai }, opDef.MfzOperator );%#ok<AGROW>
        end
        args = [ args{ : } ];

        if opDef == "If"
            result = coderapp.internal.config.expr.ConditionalOperation( mfzModel );
            result.ExprType = "CONDITIONAL";
            condEnd = floor( numel( args ) / 2 ) * 2;
            condArgs = args( 1:2:condEnd );
            branchArgs = args( 2:2:condEnd );
            for bi = 1:numel( condArgs )
                result.Branches( end  + 1 ) = coderapp.internal.config.expr.Branch( mfzModel, struct(  ...
                    'Condition', condArgs( bi ), 'Then', branchArgs( bi ) ) );
            end
            if condEnd == numel( args )
                error( 'Conditional statements must contain an else branch' );
            end
            result.Branches( end  + 1 ) = coderapp.internal.config.expr.Branch( mfzModel, struct( 'Then', args( end  ) ) );
            result.StaticType = getStaticType( [ result.Branches.Then ] );
        else
            switch opDef.StaticType
                case 'STRING'
                    result = coderapp.internal.config.expr.StringOperation( mfzModel );
                case 'BOOLEAN'
                    result = coderapp.internal.config.expr.BooleanOperation( mfzModel );
                case 'NUMBER'
                    result = coderapp.internal.config.expr.NumbericOperation( mfzModel );
                otherwise
                    result = coderapp.internal.config.expr.UntypedOperation( mfzModel,  ...
                        struct( 'StaticType', getStaticType( args ) ) );
            end
            result.ExprType = "OPERATION";
        end
        result.Operands = args;
        result.Operator = opDef.MfzOperator;
        result.Arity = opDef.Arity;
    end


    function result = parseRef( raw, parentOperator )
        tokens = strsplit( raw, '.' );
        root = tokens{ 1 };
        if symbolMap.isKey( root )
            symbol = symbolMap( root );
        elseif validateRefs
            error( 'Unrecognized symbol: %s', root );
        else
            symbol.name = root;
            symbol.subroutine = [  ];
            symbol.type = 'ANY';
        end

        if isempty( symbol.subroutine )
            for ti = 1:numel( tokens )
                if ~isvarname( tokens{ ti } )
                    error( 'Symbol names must be valid MATLAB variable names: %s', tokens{ ti } );
                end
            end
            result = coderapp.internal.config.expr.Ref( mfzModel );
            result.ExprType = "REFERENCE";
            result.Symbol = root;
            result.Subscripts = tokens( 2:end  );
            if ~isempty( symbol.type )
                result.StaticType = coderapp.internal.config.expr.ValueType( symbol.type );
            end
            if trackReferred
                referred{ end  + 1 } = root;
            end
        else
            if ~isscalar( tokens )
                error( 'Symbol "%s" refers to a subroutine and cannot be subscripted', root );
            end
            result = symbol.subroutine;
            if ~isa( result, 'coderapp.internal.config.expr.ExprValue' )
                result = parseIt( result, parentOperator );
            end
        end
    end
end


function expr = rewrite( mfzModel, expr, parentOperator )
arguments
    mfzModel
    expr
    parentOperator = [  ]
end
switch expr.ExprType
    case "OPERATION"
        operands = expr.Operands;
        switch expr.Operator
            case "NOT"
                switch operands.ExprType
                    case "OPERATION"

                        switch operands.Operator
                            case "MEMBER"
                                elideNot( expr, "NOT_MEMBER" );
                            case "NOT_MEMBER"
                                elideNot( expr, "MEMBER" );
                            case "EQ"
                                elideNot( expr, "NOT_EQ" );
                            case "GT"
                                elideNot( expr, "LT_EQ" );
                            case "GT_EQ"
                                elideNot( expr, "LT" );
                            case "LT"
                                elideNot( expr, "GT_EQ" );
                            case "LT_EQ"
                                elideNot( expr, "GT" );
                            case "HAS"
                                elideNot( expr, "NOT_HAS" )
                            case "NOT_HAS"
                                elideNot( expr, "HAS" )
                        end
                end
        end
    case [ "REFERENCE", "CONSTANT" ]


        if ~isempty( parentOperator ) && ismember( parentOperator, [ "AND", "OR", "XOR", "NOT" ] )
            eqCheck = coderapp.internal.config.expr.BooleanOperation( mfzModel );
            eqCheck.ExprType = "OPERATION";
            eqCheck.Operator = "EQ";
            eqCheck.Operands = [ expr, coderapp.internal.config.expr.BooleanConstant( mfzModel, struct( 'Value', true ) ) ];
            expr = eqCheck;
        end
end
end


function elideNot( op, repOperator )
operands = op.Operands;
op.Operator = repOperator;
op.Operands = operands.Operands;
operands.destroy(  );
end


function type = getStaticType( operands )
anyType = coderapp.internal.config.expr.ValueType.ANY;
type = setdiff( [ operands.StaticType ], anyType );
if isempty( type )
    type = anyType;
end
end



