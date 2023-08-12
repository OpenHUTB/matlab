classdef PropView < handle


properties ( Constant = true )
RowHeight = 23;



ErrorImagePath = fullfile( matlabroot, 'toolbox', 'shared', 'em_cad', '+rfpcb', '+internal', '+apps', '+transmissionLineDesigner', '+src' );
end 

properties 
Layout
end 

properties ( Access = protected )
CommonProperties = struct( Interruptible = 'off' );
ErrorHandles( 1, : )matlab.ui.control.Image
end 

properties ( Access = protected )
Parent
end 

methods 
function obj = PropView( Parent )


R36
Parent = matlab.ui.container.internal.Accordion( Parent = uigridlayout );
end 
obj.Parent = Parent;

create( obj );

layout( obj );
end 


function rtn = getErrorHandle( obj, Tag )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.PropView
Tag( 1, : )char{ mustBeNonempty }
end 
errorTags = arrayfun( @( x )x.Tag, obj.ErrorHandles, 'UniformOutput', false );
rtn = obj.ErrorHandles( contains( errorTags, Tag, 'IgnoreCase', true ) );
end 


function create( ~ )

end 


function layout( ~ )

end 

function createLayout( obj, Parent )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.PropView
Parent
end 
obj.Layout = uigridlayout( Parent = Parent, ColumnWidth = { 'fit', 'fit', 'fit' }, Padding = [ 10, 10, 10, 10 ], Scrollable = "on" );
end 

function adjustLayout( obj )

if mod( length( obj.Layout.Children ), 2 ) == 0
noOfProps = length( obj.Layout.Children );
else 
noOfProps = length( obj.Layout.Children ) + 1;
end 
rowHeight = cellfun( @( x )obj.RowHeight, cell( 1, noOfProps / 2 ), 'UniformOutput', false );
obj.Layout.RowHeight = rowHeight;


arrayfun( @( x )setColumn( x ), obj.ErrorHandles, 'UniformOutput', false );
function setColumn( inputHandle )
inputHandle.Layout.Column = 2;
end 
end 


function createErrorImage( obj, Tag )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.PropView
Tag( 1, : )char{ mustBeNonempty }
end 

if ispc
src = [ obj.ErrorImagePath, '\errorRound_12.png' ];
else 
src = [ obj.ErrorImagePath, '/errorRound_12.png' ];
end 


obj.ErrorHandles = [ obj.ErrorHandles, uiimage( Parent = obj.Layout, ImageSource = src, Tag = Tag, Visible = "off" ) ];
end 

function error( obj, Tag )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.PropView
Tag( 1, : )char{ mustBeNonempty }
end 
errorHandle = getErrorHandle( obj, Tag );
errorHandle.Visible = 'on';
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpDtdoBw.p.
% Please follow local copyright laws when handling this file.

