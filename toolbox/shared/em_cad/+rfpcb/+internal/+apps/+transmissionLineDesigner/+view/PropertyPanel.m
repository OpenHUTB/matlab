classdef PropertyPanel < rfpcb.internal.apps.transmissionLineDesigner.view.Panel







properties 
Properties
end 

methods 

function obj = PropertyPanel( Properties )





R36
Properties( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Properties{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.Properties;
end 
obj.Properties = Properties;

obj.Tag = 'propertyPanel';
obj.Title = 'Properties';

debug( obj.Properties.Logger, 'PropertyPanel = matlab.ui.internal.FigurePanel("Tag", "propertyPanel");' );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp4gKcUv.p.
% Please follow local copyright laws when handling this file.

