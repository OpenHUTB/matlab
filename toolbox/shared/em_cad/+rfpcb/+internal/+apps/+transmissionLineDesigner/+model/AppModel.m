classdef AppModel < handle









properties ( Constant = true, Hidden )

AnalysisPlotEntities = { 
'Analysis',  ...
'AnalysisPlots',  ...
'Current',  ...
'Sparameters',  ...
'Charge',  ...
'Results' };
AnalysisResultsEntities = { 
'Design',  ...
'Results',  ...
'Capacitance',  ...
'PropagationDelay',  ...
'CharacteristicImpedance',  ...
'FeedCurrent',  ...
'Inductance',  ...
'Resistance' };
VisualizationEntities = { 
'Visualization',  ...
'View2DModel',  ...
'View3DModel',  ...
'TransmissionLineGalleryModel' };
OtherEntities = { 'Properties', 'ExportSectionModel', 'FileSectionModel' };
end 


properties 

Tag = 'transmissionLineDesigner';


Names = { 'microstripLine', 'microstripBuried' };


NickNames = { 'MicrostripLine', 'Buried MicrostripLine' }

Families = { 'Transmission Lines', 'Transmission Lines', 'Transmission Lines', 'Transmission Lines' }

Frequencies = { 1000000000, 1000000000 };
end 

properties ( Dependent, SetObservable )
TransmissionLine
DesignFrequency
DesignImpedance
PlotFrequency
FrequencyRange
MainObject

State
end 


properties ( Hidden )
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;

FileSectionModel( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.FileSectionModel
Settings( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Settings
ExportSectionModel( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.ExportSectionModel

Visualization( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Visualization
View2DModel( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.View2DModel
View3DModel( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.View3DModel
TransmissionLineGalleryModel( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.TransmissionLineGalleryModel

Analysis( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Analysis
AnalysisPlots( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots
Capacitance( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Capacitance
PropagationDelay( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.PropagationDelay
CharacteristicImpedance( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.CharacteristicImpedance
Current( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Current
Design( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Design
FeedCurrent( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.FeedCurrent
Inductance( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Inductance
Resistance( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Resistance
Sparameters( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Sparameters
Charge( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Charge

Properties( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Properties

Results( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Results

AppLoading = true;
end 

properties ( Access = private )
Catalog( :, 4 )cell{ mustBeText } =  ...
{ 'microstripLine',  ...
'coplanarWaveguide',  ...
'coupledMicrostripLine',  ...
'coupledStripLine' };
pTransmissionLine{ mustBeA( pTransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
pDesignFrequency( 1, 1 )double{ mustBeNonempty, mustBeScalarOrEmpty, mustBeNonNan, mustBeFinite, mustBeReal, mustBePositive } = 1e9;
pDesignImpedance( 1, 1 )double{ mustBeNonempty, mustBeScalarOrEmpty, mustBeNonNan, mustBeFinite, mustBeReal, mustBePositive } = 50;
pPlotFrequency( 1, 1 )double{ mustBeNonempty, mustBeScalarOrEmpty, mustBeNonNan, mustBeFinite, mustBeReal, mustBePositive } = 1e9;
pFrequencyRange( 1, : )double{ mustBeNonempty, mustBeNonNan, mustBeFinite, mustBeReal, mustBePositive } = 0.5e9:0.05e9:1e9;
pState( 1, : ){ mustBeTextScalar, mustBeMember( pState, { 'New', 'Occupied', 'Running' } ) } = 'New';
end 


events 
Errored
RunningStage
CompletedStage
end 

methods 

function obj = AppModel( Logger, TransmissionLine )






R36
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = [  ];
end 
obj.Logger = Logger;
obj.TransmissionLine = TransmissionLine;
end 




function set.TransmissionLine( obj, newObject )
obj.pTransmissionLine = newObject;
if isempty( newObject )
log( obj.Logger, 'Model cleared.' );
else 
log( obj.Logger, [ '% TransmissionLine set to ', class( newObject ) ] );
end 


refreshEntities( obj, 'TransmissionLine' );
end 

function rtn = get.TransmissionLine( obj )
rtn = obj.pTransmissionLine;
end 


function set.DesignFrequency( obj, newValue )
obj.pDesignFrequency = newValue;
if isempty( newValue )
log( obj.Logger, 'Design Frequency cleared.' );
else 
log( obj.Logger, [ '% Design Frequency set to ', class( newValue ) ] );
end 


refreshEntities( obj, 'DesignFrequency' );
end 

function rtn = get.DesignFrequency( obj )
rtn = obj.pDesignFrequency;
end 


function set.DesignImpedance( obj, newValue )
obj.pDesignImpedance = newValue;
if isempty( newValue )
log( obj.Logger, 'Design Impedance cleared.' );
else 
log( obj.Logger, [ '% Design Impedance set to ', class( newValue ) ] );
end 


refreshEntities( obj, 'DesignImpedance' );
end 

function rtn = get.DesignImpedance( obj )
rtn = obj.pDesignImpedance;
end 


function set.PlotFrequency( obj, newValue )
obj.pPlotFrequency = newValue;
if isempty( newValue )
log( obj.Logger, 'Plot Frequency cleared.' );
else 
log( obj.Logger, [ '% Plot Frequency set to ', class( newValue ) ] );
end 


refreshEntities( obj, 'PlotFrequency' );
end 

function rtn = get.PlotFrequency( obj )
rtn = obj.pPlotFrequency;
end 


function set.FrequencyRange( obj, newValue )
obj.pFrequencyRange = newValue;
if isempty( newValue )
log( obj.Logger, 'Frequency Range cleared.' );
else 
log( obj.Logger, [ '% Frequency Range set to ', class( newValue ) ] );
end 


refreshEntities( obj, 'FrequencyRange' );
end 

function rtn = get.FrequencyRange( obj )
rtn = obj.pFrequencyRange;
end 

function rtn = get.MainObject( obj )
rtn = obj.pTransmissionLine;
end 

function set.State( obj, newState )
obj.pState = newState;
obj.TransmissionLine = [  ];
end 


function update( obj, ModelPart )




R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
ModelPart( 1, : ){ mustBeTextScalar } = 'TransmissionLine';
end 
try 
switch ModelPart
case 'TransmissionLine'
updateView( obj );
updateResults( obj );
case 'DesignFrequency'
updateResults( obj );
case 'PlotFrequency'
case 'FrequencyRange'
case 'Model'
update( obj, 'TransmissionLine' );
end 
catch ME
evtdata = rfpcb.internal.apps.transmissionLineDesigner.model.ErrorData( ME );
notify( obj, 'Errored', evtdata );
end 
end 
end 



methods ( Access = private )

function updateView( obj )
log( obj.Logger, '% Model for View 2D and View 3D updated.' );

update( obj.View2DModel );
update( obj.View3DModel );

end 

function updateResults( obj )

if obj.Results.IsAutoCalculate
log( obj.Logger, '% Model for results updated.' );
update( obj.Results );
end 
end 


function refreshEntities( obj, ModelPart )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
ModelPart( 1, : ){ mustBeTextScalar } = 'All';
end 

switch ModelPart
case 'TransmissionLine'

if isempty( obj.pTransmissionLine )
newDefaultFrequency = 1e9;
else 
nameclass = class( obj.pTransmissionLine );
namestr = strsplit( nameclass, '.' );
if isscalar( namestr )
newDefaultFrequency = obj.Frequencies{ strcmp( obj.Names, nameclass ) };
else 
newDefaultFrequency = obj.Frequencies{ strcmp( obj.Names, namestr{ end  } ) };
end 
end 

cellfun( @( x )set( obj.( x ), 'TransmissionLine', obj.pTransmissionLine ), obj.AnalysisPlotEntities, 'UniformOutput', false );
cellfun( @( x )set( obj.( x ), 'TransmissionLine', obj.pTransmissionLine ), obj.AnalysisResultsEntities, 'UniformOutput', false );
cellfun( @( x )set( obj.( x ), 'TransmissionLine', obj.pTransmissionLine ), obj.OtherEntities, 'UniformOutput', false );
cellfun( @( x )set( obj.( x ), 'Frequency', newDefaultFrequency ), obj.AnalysisPlotEntities, 'UniformOutput', false );
cellfun( @( x )set( obj.( x ), 'Frequency', newDefaultFrequency ), obj.AnalysisResultsEntities, 'UniformOutput', false );

cellfun( @( x )set( obj.( x ), 'TransmissionLine', obj.pTransmissionLine ), obj.VisualizationEntities, 'UniformOutput', false );
case 'DesignFrequency'

cellfun( @( x )set( obj.( x ), 'Frequency', obj.pDesignFrequency ), obj.AnalysisPlotEntities, 'UniformOutput', false );
cellfun( @( x )set( obj.( x ), 'Frequency', obj.pDesignFrequency ), obj.AnalysisResultsEntities, 'UniformOutput', false );
case 'DesignImpedance'

set( obj.Design, 'Impedance', obj.pDesignImpedance );
set( obj.CharacteristicImpedance, 'DesignImpedance', obj.pDesignImpedance );
set( obj.Sparameters, 'Impedance', obj.pDesignImpedance );
case 'PlotFrequency'

cellfun( @( x )set( obj.( x ), 'Frequency', obj.pPlotFrequency ), obj.AnalysisPlotEntities, 'UniformOutput', false );
case 'FrequencyRange'

set( obj.AnalysisPlots, 'FrequencyRange', obj.pFrequencyRange )
set( obj.Sparameters, 'FrequencyRange', obj.pFrequencyRange )
otherwise 
refreshEntities( obj, 'TransmissionLine' );
refreshEntities( obj, 'DesignFrequency' );
refreshEntities( obj, 'PlotFrequency' );
refreshEntities( obj, 'FrequencyRange' );
end 
end 
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpEZKf3V.p.
% Please follow local copyright laws when handling this file.

