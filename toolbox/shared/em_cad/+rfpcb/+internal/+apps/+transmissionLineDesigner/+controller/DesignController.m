classdef DesignController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller







methods 

function obj = DesignController( Model, App )




R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% DesignController is created.' )
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.DesignController{ mustBeNonempty };
src( 1, 1 ) = [  ];
evt( 1, 1 ) = event.EventData.empty;
end 


switch evt.EventName
case 'ValueChanged'
editFrequency( obj, src, evt );
case 'ButtonPushed'
updateDesign( obj, src, evt );
end 
end 
end 

methods ( Access = private )

function editFrequency( obj, src, evt )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.DesignController{ mustBeNonempty };
src( 1, 1 ){ mustBeA( src, { 'matlab.ui.internal.toolstrip.EditField', 'matlab.ui.internal.toolstrip.DropDown' } ) } = [  ];
evt( 1, 1 )matlab.ui.internal.toolstrip.base.ToolstripEventData = [  ];
end 


freqString = obj.App.DesignView.DesignFrequencyEditField.Value;
unit = obj.App.DesignView.DesignFrequencyUnitDropdown.Items{ obj.App.DesignView.DesignFrequencyUnitDropdown.SelectedIndex };
if isa( src, 'matlab.ui.internal.toolstrip.EditField' )
freqString = obj.App.DesignView.DesignFrequencyEditField.Value;
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

validateattributes( frequency, { 'numeric' },  ...
{ 'nonempty', 'finite', 'real', 'positive',  ...
'scalar', '>', 1000, '<', 200e9 },  ...
'design frequency', 'design frequency' );
obj.Model.DesignFrequency = frequency;
end 


function updateDesign( obj, src, evt )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.DesignController{ mustBeNonempty };
src( 1, 1 )matlab.ui.internal.toolstrip.Button = [  ];
evt( 1, 1 )event.EventData = [  ];%#ok<INUSA>
end 


try 
if isempty( obj.Model.TransmissionLine )
obj.Model.TransmissionLine = microstripLine;
end 
obj.Model.TransmissionLine = compute( obj.Model.Design, 'SuppressOutput', false );
src.Enabled = false;
catch ME
error( obj.App, ME );
src.Enabled = true;
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpNwesgu.p.
% Please follow local copyright laws when handling this file.

