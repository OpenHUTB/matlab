classdef PlotInputsController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller







properties ( Dependent, Access = private )
SelectedEditField
SelectedDropdown
end 

properties ( Hidden )
SelectedFrequency
end 

methods 

function obj = PlotInputsController( Model, App )




R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '%  PlotInputsController is created.' )
end 



function rtn = get.SelectedEditField( obj )
switch obj.SelectedFrequency
case 'PlotFrequency'
rtn = 'PlotFrequencyEditField';
case 'FrequencyRange'
rtn = 'FrequencyRangeEditField';
end 
end 

function rtn = get.SelectedDropdown( obj )
switch obj.SelectedFrequency
case 'PlotFrequency'
rtn = 'PlotFrequencyUnitDropdown';
case 'FrequencyRange'
rtn = 'FrequencyRangeUnitDropdown';
end 
end 

function setSelectedFrequency( obj, src )
switch src.Tag
case { 'plotFrequencyEditField', 'plotFrequencyUnitDropdown' }
obj.SelectedFrequency = 'PlotFrequency';
case { 'frequencyRangeEditField', 'frequencyRangeUnitDropdown' }
obj.SelectedFrequency = 'FrequencyRange';

end 
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.PlotInputsController{ mustBeNonempty };
src = [  ];
evt = [  ];
end 


editFrequency( obj, src, evt );


log( obj.Model.Logger, '% Frequency range changed.' );
end 
end 

methods ( Access = private )

function editFrequency( obj, src, evt )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.PlotInputsController{ mustBeNonempty };
src( 1, 1 ){ mustBeA( src, { 'matlab.ui.internal.toolstrip.EditField', 'matlab.ui.internal.toolstrip.DropDown' } ) } = [  ];
evt( 1, 1 )matlab.ui.internal.toolstrip.base.ToolstripEventData = [  ];
end 


setSelectedFrequency( obj, src );


freqString = obj.App.PlotInputsView.( obj.SelectedEditField ).Value;
unit = obj.App.PlotInputsView.( obj.SelectedDropdown ).Items{ obj.App.PlotInputsView.( obj.SelectedDropdown ).SelectedIndex };

if isa( src, 'matlab.ui.internal.toolstrip.EditField' )
freqString = src.Value;
elseif isa( src, 'matlab.ui.internal.toolstrip.DropDown' )
unit = src.Items{ src.SelectedIndex };
end 


try 
apply( obj, freqString, unit );
catch ME

src.Value = evt.EventData.OldValue;
error( obj.App, ME );
end 


log( obj.Model.Logger, '% Design Frequency Edited.' );
end 


function apply( obj, freqString, unit )
frequency = evalin( 'base', freqString );
frequency = rfpcb.internal.apps.applyUnit( frequency, unit );

switch obj.SelectedFrequency
case 'PlotFrequency'

validateattributes( frequency, { 'numeric' },  ...
{ 'nonempty', 'finite', 'real', 'positive', 'scalar',  ...
'>', 1000, '<', 200e9 },  ...
'plot frequency', 'plot frequency' );
case 'FrequencyRange'

validateattributes( frequency, { 'numeric' },  ...
{ 'nonempty', 'finite', 'real', 'positive', 'vector',  ...
'>', 1000, '<', 200e9 },  ...
'frequency range', 'frequency range' );
end 
obj.Model.( obj.SelectedFrequency ) = frequency;
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmphUfRXc.p.
% Please follow local copyright laws when handling this file.

