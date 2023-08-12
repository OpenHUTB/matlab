function [ out, repeatedAssignments, activeObservables ] = genEquations( model, configset, variants, doses, options )






























R36
model( 1, 1 )SimBiology.Model
configset{ SimBiology.internal.ValidationHelper.emptyOrValidateattributes( configset, { 'SimBiology.Configset' }, { 'scalar' } ) } = getconfigset( model, 'active' )
variants{ SimBiology.internal.ValidationHelper.emptyOrValidateattributes( variants, { 'SimBiology.Variant' }, { 'vector' } ) } = [  ]
doses{ SimBiology.internal.ValidationHelper.emptyOrValidateattributes( doses, { 'SimBiology.Dose' }, { 'vector' } ) } = [  ]
options.EmbedFlux( 1, 1 )logical = false


options.WarnIfInitialConditionSetByAlgebraicRule( 1, 1 )logical = true
end 


numRequiredArgs = 1;
optionalArgNames = { 'configset', 'variants', 'doses' };
numAllPositionalArgs = numRequiredArgs + numel( optionalArgNames );
if nargin == numRequiredArgs

configset = model.getconfigset( 'active' );
if isempty( configset )
error( message( 'SimBiology:getequations:NoActiveConfigset' ) );
end 
verifyArguments = {  };
doses = findobj( model.getdose, 'Active', true );
elseif nargin == numAllPositionalArgs

if isempty( configset )

configset = model.getconfigset( 'active' );
elseif ~any( configset == model.getconfigset )
error( message( 'SimBiology:getequations:ConfigsetNotAttached' ) );
end 
verifyArguments = { configset, variants, doses };
else 

numMissingArguments = numAllPositionalArgs - nargin;
missingArgNames = SimBiology.internal.getCommaSeparatedStringFromCellstr( optionalArgNames( end  + 1 - numMissingArguments:end  ) );
error( message( 'SimBiology:getequations:MissingArguments', missingArgNames ) );
end 
if ~isa( configset.SolverOptions, 'SimBiology.ODESolverOptions' )
error( message( 'SimBiology:getequations:InvalidSolverType' ) );
end 

SimBiology.internal.verifyHelper( model, verifyArguments{ : }, "RequireObservableDependencies", false );

odedata = model.ODESimulationData;
assert( ~isempty( odedata ), message( 'SimBiology:Internal:InternalError' ) );
equations = odedata.EquationViewData;



equations.ActiveDoses = doses;


fluxBaseName = findUniqueFluxName( model, equations.ReactionNames );
if numel( equations.RawReactionCode ) > 0
for i = 1:numel( equations.RawReactionCode )
flux = SimBiology.internal.Equations.Equation;
name = equations.ReactionNames{ i };
if isempty( name )
name = sprintf( '%s%d', fluxBaseName, i );
elseif ~isvarname( name )
name = sprintf( '[%s]', name );
end 
flux.lhs = name;
flux.operator = '=';
flux.rhs = equations.RawReactionCode{ i };
equations.Fluxes( i ) = flux;
end 
end 








allComponents = [ odedata.X0Objects;odedata.PObjects ];
allNames = { allComponents.Name };
[ ~, ~, uniqueNameIndex ] = unique( allNames );
counts = accumarray( uniqueNameIndex, 1 );
counts = counts( uniqueNameIndex );
nameMap = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );
allUuids = { allComponents.UUID };
for i = 1:numel( allUuids )
thisUuid = allUuids{ i };
if counts( i ) == 1
thisName = allComponents( i ).Name;
if ~isvarname( thisName )
thisName = [ '[', thisName, ']' ];%#ok<AGROW>
end 
nameMap( thisUuid ) = thisName;
else 
nameMap( thisUuid ) = allComponents( i ).QualifiedName;
end 
end 

function out = getUsableName( valueObj )
out = nameMap( valueObj.UUID );
end 






[ col, row, stoich ] = find( odedata.Stoich' );



row = reshape( row, 1, [  ] );
col = reshape( col, 1, [  ] );
stoich = reshape( stoich, 1, [  ] );





iEnd = [ find( row( 1:end  - 1 ) ~= row( 2:end  ) ), numel( stoich ) ];
iStart = [ 1, iEnd( 1:end  - 1 ) + 1 ];

numConstComp = size( odedata.speciesIndexToConstantCompartment, 1 );
numVarComp = size( odedata.speciesIndexToVaryingCompartment, 1 );


constXUUIDs = odedata.constantXUuids;

for iRow = 1:size( odedata.Stoich, 1 )
stoichAndRateIndex = [ stoich( iStart( iRow ):iEnd( iRow ) );col( iStart( iRow ):iEnd( iRow ) ) ];

dxdt = SimBiology.internal.Equations.Equation;
species = odedata.X0Objects( iRow );
speciesName = getUsableName( species );
hasRateDose = equations.HasRateDoseX( iRow );
rateDoseName = equations.RateDoseNameX{ iRow };
dxdt.lhs = [ 'd(', speciesName, ')/dt' ];
assert( ~isempty( stoichAndRateIndex ), 'Internal error. Unexpected stoichiometry.' );



numTerms = size( stoichAndRateIndex, 2 );
rawRateCell = cell( 1, numTerms );
for j = 1:numTerms
stoichTerm = stoichAndRateIndex( 1, j );
rateIndex = stoichAndRateIndex( 2, j );

if options.EmbedFlux



fluxName = [ '(', equations.Fluxes( rateIndex ).rhs, ')' ];
else 
fluxName = equations.Fluxes( rateIndex ).lhs;
end 

switch stoichTerm
case 1
if j == 1
rateTerm = fluxName;
else 
rateTerm = [ ' + ', fluxName ];
end 
case  - 1
if j == 1
rateTerm = [ '-', fluxName ];
else 
rateTerm = [ ' - ', fluxName ];
end 
otherwise 
if j == 1
rateTerm = sprintf( '%.17g*%s', stoichTerm, fluxName );
elseif stoichTerm > 0
rateTerm = sprintf( ' + %.17g*%s', stoichTerm, fluxName );
else 
rateTerm = sprintf( ' - %.17g*%s', abs( stoichTerm ), fluxName );
end 
end 
rawRateCell{ j } = rateTerm;
rawRate = [ rawRateCell{ : } ];



speciesIdxComp = [ [ odedata.speciesIndexToConstantCompartment, zeros( numConstComp, 1 ) ];[ odedata.speciesIndexToVaryingCompartment, ones( numVarComp, 1 ) ] ];



idx = find( speciesIdxComp( :, 1 ) == iRow );

if ~isempty( idx )
if speciesIdxComp( idx, 3 )
compartment = odedata.X0Objects( speciesIdxComp( idx, 2 ) );
compartmentName = compartment.QualifiedName;
if ~any( strcmp( constXUUIDs, compartment.UUID ) )
dxdt.rhs = [ '1/', compartmentName, '*(', rawRate, ' - ', speciesName, '*d(', compartmentName, ')/dt)' ];
else 
dxdt.rhs = [ '1/', compartmentName, '*(', rawRate, ')' ];
end 
else 
compartmentName = odedata.PObjects( speciesIdxComp( idx, 2 ) ).QualifiedName;
dxdt.rhs = [ '1/', compartmentName, '*(', rawRate, ')' ];
end 
else 
dxdt.rhs = rawRate;
end 

if ( hasRateDose )
dxdt.rhs = [ dxdt.rhs, ' + ', rateDoseName ];
end 
end 

equations.ODE( iRow, 1 ) = dxdt;
end 


equations.ODE = [ equations.ODE;equations.RateRules;equations.SpeciesRateRules ];


for i = 1:numel( equations.SpeciesInConcentrationInVaryingCompartments )
species = equations.SpeciesInConcentrationInVaryingCompartments( i );
if ~any( strcmp( constXUUIDs, species.Parent.UUID ) )
dxdt = SimBiology.internal.Equations.Equation;
speciesName = getUsableName( species );
compartmentName = species.Parent.PartiallyQualifiedName;
dxdt.lhs = [ 'd(', speciesName, ')/dt' ];
dxdt.rhs = [ '1/', compartmentName, '*(-', speciesName, '*d(', compartmentName, ')/dt)' ];
equations.ODE( end  + 1 ) = dxdt;
end 
end 


unitConversion = ~isempty( odedata.XUCM ) || ~isempty( odedata.PUCM );
[ initialValuesInUserUnits, parameterValuesInUserUnits ] = SimBiology.internal.getInitialValues( odedata );

for i = 1:numel( odedata.X0Objects )
temp = SimBiology.internal.Equations.Equation;
temp.lhs = getUsableName( odedata.X0Objects( i ) );
temp.rhs = num2str( initialValuesInUserUnits( i ), 5 );
if unitConversion
temp.units = odedata.X0Objects( i ).Units;
end 
equations.InitialConditions( i ) = temp;
end 


if ~isempty( odedata.algebraicXUuids )
tfIsAlgebraic = ismember( odedata.XUuids, odedata.algebraicXUuids );
equations.InitialConditions( tfIsAlgebraic ) = [  ];
names = { odedata.X0Objects( tfIsAlgebraic ).QualifiedName };
if options.WarnIfInitialConditionSetByAlgebraicRule
warning( message( 'SimBiology:getequations:AlgebraicVariables', strjoin( names, ", " ) ) );
end 
end 


for i = 1:numel( odedata.PObjects )
temp = SimBiology.internal.Equations.Equation;
temp.lhs = getUsableName( odedata.PObjects( i ) );
temp.rhs = num2str( parameterValuesInUserUnits( i ), 5 );
if unitConversion
temp.units = odedata.PObjects( i ).Units;
end 
equations.ParameterValues( i ) = temp;
end 


activeObservables = model.Observables( [ model.Observables.Active ] );
activeObservables = activeObservables( equations.ObservableEvaluationOrder );
for i = numel( activeObservables ): - 1:1
observable = activeObservables( i );
name = observable.Name;
if ~isvarname( name )
name = sprintf( '[%s]', name );
end 
equation = SimBiology.internal.Equations.Equation;
equation.lhs = name;
equation.operator = '=';
equation.rhs = observable.Expression;
if unitConversion
equation.units = observable.Units;
end 
equations.Observables( i ) = equation;
end 


dosestr = cell( numel( equations.ActiveDoses ) + 3, 1 );
if ~isempty( equations.ActiveDoses )
dosestr{ 1 } = sprintf( 'Doses:\n' );
dosestr{ 2 } = sprintf( '%s\t%s\t%s\n', padstring( 'Variable', 30 ), padstring( 'Type', 20 ), padstring( 'Units', 20 ) );
for i = 1:numel( equations.ActiveDoses )
dose = equations.ActiveDoses( i );
dosestr{ 2 + i } = sprintf( '%s\t%s\t%s\n', padstring( dose.TargetName, 30 ), padstring( dose.Type, 20 ), padstring( dose.AmountUnits, 20 ) );
end 
dosestr{ end  } = newline;
end 


eventstr = cell( numel( equations.ActiveEvents ) + 3, 1 );
if ~isempty( equations.ActiveEvents )
eventstr{ 1 } = sprintf( 'Events:\n' );
eventstr{ 2 } = sprintf( '%s\t%s\t%s\n', padstring( 'Name', 30 ), padstring( 'Trigger', 30 ), padstring( 'Function', 30 ) );
for i = 1:numel( equations.ActiveEvents )
event = equations.ActiveEvents( i );
fcns = event.EventFcns;

functionstr = '';
for j = 2:numel( fcns )
functionstr = [ functionstr, sprintf( '%s\t%s\t%s\n', padstring( '', 30 ), padstring( '', 30 ), padstring( fcns{ j }, 30 ) ) ];%#ok<AGROW>
end 
eventstr{ 2 + i } = sprintf( '%s\t%s\t%s\n%s', padstring( event.Name, 30 ), padstring( event.Trigger, 30 ), padstring( fcns{ 1 }, 30 ), functionstr );
end 
end 


out = [ equations.toString(  ), dosestr{ : }, eventstr{ : } ];


if nargout > 1
ruleUuids = equations.RepeatedAssignmentRuleUUIDs;
if numel( ruleUuids ) > 0
allRuleUuids = get( model.Rules, { 'UUID' } );
[ tf, idx ] = ismember( ruleUuids, allRuleUuids );
repeatedAssignments = model.Rules( idx( tf ) );
else 
repeatedAssignments = [  ];
end 
end 
end 


function out = padstring( str, len )
if numel( str ) < len
out = [ str, repmat( ' ', [ 1, len - numel( str ) ] ) ];
else 
out = [ str( 1:len - 4 ), '...' ];
end 
end 


function name = findUniqueFluxName( model, reactionNames )




baseName = 'ReactionFlux';
objs = SimBiology.internal.getAllQuantityObjects( model );
names = [ get( objs, { 'Name' } );reactionNames( : ) ];
expr = [ '^', baseName, '[0-9]+' ];
matches = cell2mat( regexp( names, expr, 'once' ) );
while ~isempty( matches )
baseName = [ baseName, '_' ];%#ok<AGROW>
expr = [ '^', baseName, '[0-9]+' ];
matches = cell2mat( regexp( names, expr, 'once' ) );
end 
name = baseName;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_rrUSV.p.
% Please follow local copyright laws when handling this file.

