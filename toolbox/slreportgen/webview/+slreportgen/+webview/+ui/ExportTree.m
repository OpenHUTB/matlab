classdef ExportTree < handle




properties ( Dependent )
ID
PID
Children
DisplayLabel
end 

properties ( Access = private )
Source
IsCacheEnabled
end 

methods 

function this = ExportTree( source )
R36
source = [  ];
end 
this.Source = source;
this.IsCacheEnabled = isa( source, 'slreportgen.webview.internal.Diagram' );
end 

function id = get.ID( this )
if ~isempty( this.Source )
id = this.Source.ID;
else 
id = 1;
end 
end 

function pid = get.PID( this )
if ~isempty( this.Source )
if this.IsCacheEnabled
pid = this.Source.Parent.ID;
else 
pid = this.Source.getParent(  ).ID;
end 
else 
pid = [  ];
end 
end 

function children = get.Children( this )
children = this.getHierarchicalChildren(  );
end 

function label = get.DisplayLabel( this )
label = this.getDisplayLabel(  );
end 


function label = getDisplayLabel( this )
if ~isempty( this.Source )
label = char( this.Source.DisplayLabel );
else 
label = 'Simulink';
end 
end 


function icon = getDisplayIcon( this )
if ~isempty( this.Source )
if this.IsCacheEnabled
icon = strrep( this.Source.DisplayIcon, "$matlabroot", matlabroot );
else 
icon = this.Source.getDisplayIcon(  );
end 
else 
icon = fullfile( matlabroot, 'toolbox/slreportgen/webview/resources/icons/SimulinkRoot.png' );
end 
end 


function tf = hasChildren( this )
tf = ~isempty( this.Source ) && this.Source.hasChildren(  );
end 


function children = getHierarchicalChildren( this )
if ~isempty( this.Source )
if this.IsCacheEnabled
srcChildren = this.Source.Children;
srcChildren = srcChildren( [ srcChildren.Visible ] );
else 
srcChildren = this.Source.getChildren(  );
end 

n = numel( srcChildren );
children = cell( ( n > 0 ), n );
for i = 1:n
children{ i } = slreportgen.webview.ui.ExportTree( srcChildren( i ) );
end 
else 
children = {  };
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUL2r9k.p.
% Please follow local copyright laws when handling this file.

