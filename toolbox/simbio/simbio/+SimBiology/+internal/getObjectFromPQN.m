function result = getObjectFromPQN( modelObj, pqnInput, type, nameValueArgs )

arguments
    modelObj( 1, 1 )SimBiology.Model
    pqnInput{ mustBeText }
    type( 1, : )char = '';
    nameValueArgs.ReturnCellForScalarText( 1, 1 )logical = ~ischar( pqnInput )
end

pqnInput = cellstr( pqnInput );
type = lower( type );

result = cell( size( pqnInput ) );
tfEmpty = cellfun( @isempty, pqnInput );
result( ~tfEmpty ) = localGetObjectFromPQN( modelObj, pqnInput( ~tfEmpty ), type );
if ~nameValueArgs.ReturnCellForScalarText && isscalar( pqnInput )
    result = result{ 1 };
end
end

function objCell = localGetObjectFromPQN( modelObj, pqnCell, type )
if isempty( type )




    objCell = getSpeciesFromPQN( modelObj, pqnCell );


    tfEmpty1 = cellfun( @isempty, objCell );
    [ names1, types1 ] = SimBiology.internal.parsePQN( pqnCell( tfEmpty1 ) );
    objCell1 = getCompartmentFromPQN( modelObj, names1, types1 );


    tfEmpty2 = cellfun( @isempty, objCell1 );
    names2 = names1( tfEmpty2 );
    types2 = types1( tfEmpty2 );
    objCell2 = getParameterFromPQN( modelObj, names2, types2 );


    tfEmpty3 = cellfun( @isempty, objCell2 );
    names3 = names2( tfEmpty3 );
    types3 = types2( tfEmpty3 );
    objCell3 = getObservablesFromPQN( modelObj, names3, types3 );


    objCell2( tfEmpty3 ) = objCell3;
    objCell1( tfEmpty2 ) = objCell2;
    objCell( tfEmpty1 ) = objCell1;
else
    switch ( type )
        case 'species'
            objCell = getSpeciesFromPQN( modelObj, pqnCell );
        case 'compartment'
            [ names, types ] = SimBiology.internal.parsePQN( pqnCell );
            objCell = getCompartmentFromPQN( modelObj, names, types );
        case 'parameter'
            [ names, types ] = SimBiology.internal.parsePQN( pqnCell );
            objCell = getParameterFromPQN( modelObj, names, types );
        case 'observable'
            [ names, types ] = SimBiology.internal.parsePQN( pqnCell );
            objCell = getObservablesFromPQN( modelObj, names, types );
        otherwise
            error( message( 'SimBiology:Internal:InternalError' ) );
    end
end
end

function objCell = getSpeciesFromPQN( modelObj, pqn )






















validateattributes( modelObj, { 'SimBiology.Model' }, { 'scalar' }, mfilename, 'modelObj' );

if ischar( pqn )
    pqn = { pqn };
end


objCell = matchUsingPQNs( modelObj, pqn );


tfEmpty = cellfun( @isempty, objCell );
objCell( tfEmpty ) = matchUsingNames( modelObj, pqn( tfEmpty ) );
end

function objCell = getCompartmentFromPQN( modelObj, names, types )
objCell = cell( size( names ) );
if isempty( names )
    return
end

tfShort = strcmp( types, 'short' );
shortNames = vertcat( names{ tfShort } );
objCell( tfShort ) = sortedSbioselectQuery( modelObj, 'Name', shortNames, 'compartment' );
end

function objCell = getParameterFromPQN( modelObj, names, types )
objCell = cell( size( names ) );
if isempty( names )
    return
end
tfShort = strcmp( types, 'short' );
shortNames = vertcat( names{ tfShort } );
objCell( tfShort ) = sortedSbioselectQuery( modelObj, 'Name', shortNames, 'parameter', 'depth', 1 );


[ reactionNames, parameterNames ] = getParentAndChildNames( names( ~tfShort ), types( ~tfShort ) );

allReactions = sortedSbioselectQuery( modelObj, 'Name', reactionNames, 'reaction', 'depth', 1 );
objCell( ~tfShort ) = matchNamesWithinParents( vertcat( allReactions{ : } ), parameterNames, 'parameter' );
end

function objCell = getObservablesFromPQN( modelObj, names, types )
objCell = cell( size( names ) );
if isempty( names )
    return
end

tfShort = strcmp( types, 'short' );
shortNames = vertcat( names{ tfShort } );
objCell( tfShort ) = sortedSbioselectQuery( modelObj, 'Name', shortNames, 'observable' );
end

function objCell = matchUsingPQNs( modelObj, pqn )
if isempty( pqn )
    objCell = {  };
    return
end
objCell = sortedSbioselectQuery( modelObj, 'PartiallyQualifiedName', pqn, 'species' );
end

function objCell = matchUsingNames( modelObj, pqn )
objCell = cell( size( pqn ) );
if isempty( pqn )
    return
end
[ names, types ] = SimBiology.internal.parsePQN( pqn );
tfShort = strcmp( types, 'short' );
objCell( tfShort ) = matchShortNames( modelObj, vertcat( names{ tfShort } ) );
objCell( ~tfShort ) = matchOtherNames( modelObj, names( ~tfShort ), types( ~tfShort ) );
end

function objCell = matchShortNames( modelObj, pqn )
if isempty( pqn )
    objCell = {  };
    return
end
objCell = sortedSbioselectQuery( modelObj, 'Name', pqn, 'species' );
end

function objCell = matchOtherNames( modelObj, names, types )
objCell = cell( size( names ) );
if isempty( names )
    return
end
[ compartmentNames, shortSpeciesNames ] = getParentAndChildNames( names, types );
compartmentObjs = sortedSbioselectQuery( modelObj, 'Name', compartmentNames, 'compartment', 'depth', 1 );
tfEmpty = cellfun( @isempty, compartmentObjs );
objCell( ~tfEmpty ) = matchNamesWithinParents( vertcat( compartmentObjs{ ~tfEmpty } ), shortSpeciesNames( ~tfEmpty ), 'species' );
end

function [ parentNames, childNames ] = getParentAndChildNames( names, types )
tfPqn = strcmp( types, 'pqn' );
parentNames = cell( size( names ) );
childNames = cell( size( names ) );

parentNames( tfPqn ) = cellfun( @( n )n{ 1 }, names( tfPqn ), 'UniformOutput', false );
childNames( tfPqn ) = cellfun( @( n )n{ 2 }, names( tfPqn ), 'UniformOutput', false );

parentNames( ~tfPqn ) = cellfun( @( n )n{ 2 }, names( ~tfPqn ), 'UniformOutput', false );
childNames( ~tfPqn ) = cellfun( @( n )n{ 3 }, names( ~tfPqn ), 'UniformOutput', false );
end

function objCell = matchNamesWithinParents( parentObjs, names, componentType )
objCell = cell( size( names ) );
if isempty( names )
    return
end
[ uniqueParents, ~, ic ] = unique( parentObjs );
for i = 1:numel( uniqueParents )
    idx = ( i == ic );
    objCell( idx ) = matchNamesWithinOneParent( uniqueParents( i ), names( idx ), componentType );
end
end

function objCell = matchNamesWithinOneParent( compartmentObj, names, componentType )
if isempty( names )
    objCell = {  };
    return
end
objCell = sortedSbioselectQuery( compartmentObj, 'Name', names, componentType );
end

function objCell = sortedSbioselectQuery( parentObj, propertyName, propertyValues, objectType, varargin )
if isempty( propertyValues )

    objCell = {  };
elseif isscalar( propertyValues )

    objCell = { sbioselect( parentObj, propertyName, propertyValues{ 1 }, 'Type', objectType, varargin{ : } ) };
else
    [ uniqueValues, ~, ic ] = unique( propertyValues );
    sortedObjArray = cell( size( uniqueValues ) );
    unsortedObj = sbioselect( parentObj, propertyName, uniqueValues, 'Type', objectType, varargin{ : } );
    unsortedValues = get( unsortedObj, { propertyName } );
    [ ~, loc ] = ismember( unsortedValues, uniqueValues );
    uniqueLoc = unique( loc );
    for i = 1:numel( uniqueLoc )
        aLoc = uniqueLoc( i );
        sortedObjArray{ aLoc } = unsortedObj( loc == aLoc );
    end
    objCell = sortedObjArray( ic );
end
end

