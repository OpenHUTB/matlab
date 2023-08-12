function [ globalTable, ncaOptions ] = dataFromSD( dataSet, ncaOptions )






R36
dataSet( :, 1 )struct
ncaOptions( 1, 1 )SimBiology.nca.Options
end 

if ~isscalar( dataSet )
error( message( 'SimBiology:NCA:DataSetStructMustBeScalar' ) );
end 

if ~all( isfield( dataSet, { 'simdata', 'dose' } ) )
error( message( 'SimBiology:NCA:InvalidSimData_Dose_Input' ) );
end 

dose = dataSet.dose;
sdAll = dataSet.simdata;

if ~sdAll.IsHomogeneous(  )
error( message( 'SimBiology:NCA:HeterogeneousSimDataArray' ) );
end 

if isempty( dose )
error( message( 'SimBiology:NCA:DoseInformationMissing' ) );
end 

switch class( dose )
case 'table'




expectedNames1 = [ "Time", "Amount", "Rate" ];
expectedNames2 = [ "StartTime", "Amount", "Rate", "Interval", "RepeatCount" ];
givenNames = string( dose.Properties.VariableNames );

tfScheduleTable = isequal( sort( expectedNames1 ), sort( givenNames ) );
tfRepeatTable = isequal( sort( expectedNames2 ), sort( givenNames ) );

if ~( tfScheduleTable || tfRepeatTable )
error( message( 'SimBiology:NCA:InvalidDoseTable' ) );
end 
case 'SimBiology.RepeatDose'

if ~isscalar( dose ) && numel( sdAll ) ~= numel( dose )
error( message( 'SimBiology:NCA:SimDataDoseSizeMismatch' ) );
end 

otherwise 
error( message( 'SimBiology:NCA:InvalidDose' ) );
end 

globalTable = table;


if isa( dose, 'SimBiology.RepeatDose' )
if isscalar( dose )
dose = repmat( dose, numel( sdAll ), 1 );
end 
doseInTableForm = false;
else 
dose = repmat( { dose }, numel( sdAll ), 1 );
doseInTableForm = true;
end 

requestedNames = ncaOptions.concentrationColumnName;

for i = 1:numel( sdAll )
sd = sdAll( i );

[ timeData, stateData, warnTokens ] = sd.selectbyname( requestedNames, 'WarnNames', true );

if ~isempty( warnTokens )
error( message( 'SimBiology:NCA:InvalidConcentrationColumnNameValue' ) );
end 

t = array2table( [ timeData, stateData ], 'VariableNames', [ "Time", requestedNames ] );





if ~doseInTableForm
doseTable = getDoseTable( dose( i ) );
elseif tfRepeatTable
doseTable = getDoseTable( dose{ i } );
else 
doseTable = dose{ i };
end 





[ ~, IA ] = unique( t.Time, 'rows', 'last' );
t = t( IA, : );

oralSimData = outerjoin( t, doseTable, 'keys', 'Time', 'MergeKeys', true );



oralSimData.Group = cellstr( repmat( num2str( i ), height( oralSimData ), 1 ) );

globalTable = vertcat( globalTable, oralSimData );
end 
end 

function doseTable = getDoseTable( doseInfo )
times = ( ( 0:doseInfo.RepeatCount ) * doseInfo.Interval + doseInfo.StartTime )';
amts = repmat( doseInfo.Amount, numel( times ), 1 );
doseTable = table( times, amts, 'VariableNames', { 'Time', 'Amount' } );
end 

function [ stateNames, stateNameNoPQN ] = getPQNFromSimData( sd )
di = sd.DataInfo;
stateNames = string.empty( numel( di ), 0 );
for i = 1:numel( di )
di_i = di{ i };
switch di_i.Type
case 'species'
stateNames( i ) = sprintf( "%s.%s", di_i.Compartment, di_i.Name );
case 'parameter'
if ~isempty( di_i.Reaction )
stateNames( i ) = sprintf( "%s.%s", di_i.Reaction, di_i.Name );
else 
stateNames( i ) = string( di_i.Name );
end 
case { 'compartment', 'observable' }
stateNames( i ) = string( di_i.Name );
end 
stateNameNoPQN( i ) = string( di_i.Name );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKIiy6M.p.
% Please follow local copyright laws when handling this file.

