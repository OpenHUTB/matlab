function [ values, changed ] = evaluate( exprs, variables, storeObjects )
arguments
    exprs coderapp.internal.config.expr.ExprValue
    variables( 1, 1 )struct = struct(  )
    storeObjects( 1, 1 ){ mustBeNumericOrLogical( storeObjects ) } = false
end

context.variables = variables;
context.storeObjects = storeObjects;
values = cell( size( exprs ) );
changed = false( size( values ) );

for i = 1:numel( exprs )
    [ values{ i }, changed( i ) ] = evalExpr( exprs( i ), context );
end
end


function [ result, changed ] = evalExpr( expr, context )


switch extractAfter( class( expr ), 'coderapp.internal.config.expr.' )
    case { 'StringConstant', 'BooleanConstant', 'NumericConstant' }
        result = expr.Value;
        changed = false;
    case 'Ref'
        [ result, changed ] = evalRef( expr, context );
    case { 'UntypedOperation', 'StringOperation', 'NumericOperation', 'BooleanOperation' }
        [ result, changed ] = evalOperation( expr, context );
    case 'ConditionalOperation'
        [ result, changed ] = evalIfThen( expr, context );
end
if changed
    expr.Active = true;
end
end


function [ rawValue, changed ] = evalRef( ref, context )
symbol = ref.Symbol;
if isfield( context.variables, symbol )
    rawValue = context.variables.( symbol );
else
    error( 'Undefined variable: %s', symbol );
end
subscripts = ref.Subscripts;
for si = 1:numel( subscripts )
    rawValue = rawValue.( subscripts{ si } );
end
isObj = isobject( rawValue );
changed = ~ref.Active || ~ref.Comparable || isObj || ~isequal( rawValue, ref.Value );
if changed
    if ~isObj || context.storeObjects
        ref.Value = rawValue;
        ref.Comparable = true;
    else
        ref.Value = [  ];
        ref.Comparable = false;
    end
end
end


function [ result, changed ] = evalOperation( expr, context )
operands = expr.Operands;
args = cell( size( operands ) );
changed = ~expr.Active;
for oi = 1:numel( operands )
    [ args{ oi }, aChanged ] = evalExpr( operands( oi ), context );
    changed = changed || aChanged;
end
if changed
    opDef = coderapp.internal.config.expr.OpDefs.fromMfzOperator( expr.Operator );
    result = opDef.Evaluator( args{ : } );
    expr.Value = result;
else
    result = expr.Value;
end
end


function [ result, changed ] = evalIfThen( expr, context )
passed = false;
result = [  ];
prevActive = expr.ActiveBranch;
changed = ~expr.Active || isempty( prevActive );

for branch = expr.Branches
    cond = branch.Condition;
    then = branch.Then;
    if passed
        if ~isempty( cond )
            markDead( cond );
        end
        markDead( then );
    else
        passed = isempty( cond ) || evalExpr( cond, context );
        if passed
            [ result, aChanged ] = evalExpr( then, context );
            changed = changed || aChanged || prevActive ~= branch;
            expr.ActiveBranch = branch;
        else
            markDead( then );
        end
    end
end
if changed
    expr.Value = result;
end
end


function markDead( expr )
switch expr.ExprType
    case [ "OPERATION", "CONDITIONAL" ]
        for operand = expr.Operands
            markDead( operand );
        end
        expr.Value = cast( [  ], class( expr.Value ) );
    case "REF"
        expr.Value = [  ];
    otherwise
        return
end
expr.Active = false;
end



