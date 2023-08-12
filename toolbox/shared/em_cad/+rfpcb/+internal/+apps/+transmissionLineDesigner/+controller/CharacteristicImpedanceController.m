classdef CharacteristicImpedanceController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller







methods 

function obj = CharacteristicImpedanceController( Model, App )




R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% CharacteristicImpedanceController is created.' )
end 


function process( obj, src, evt )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.CharacteristicImpedanceController{ mustBeNonempty };
src( 1, 1 ) = [  ];
evt( 1, 1 ) = event.EventData.empty;
end 


editImpedance( obj, src, evt );
end 
end 

methods ( Access = private )

function editImpedance( obj, src, evt )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.CharacteristicImpedanceController{ mustBeNonempty };
src( 1, 1 ){ mustBeA( src, { 'matlab.ui.internal.toolstrip.EditField' } ) } = [  ];
evt( 1, 1 )matlab.ui.internal.toolstrip.base.ToolstripEventData = [  ];
end 


impString = obj.App.DesignView.ImpedanceEditField.Value;


try 
apply( obj, impString );
catch ME
src.Value = evt.EventData.OldValue;
error( obj.App, ME );
end 

log( obj.Model.Logger, '% Design Impedance Edited.' );
end 


function apply( obj, impString )
impedance = evalin( 'base', impString );

validateattributes( impedance, { 'numeric' },  ...
{ 'nonempty', 'finite', 'real', 'positive',  ...
'scalar', '>', 10, '<', 300 },  ...
'impedance', 'impedance' );
obj.Model.DesignImpedance = impedance;
end 

end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp3KNY0v.p.
% Please follow local copyright laws when handling this file.

