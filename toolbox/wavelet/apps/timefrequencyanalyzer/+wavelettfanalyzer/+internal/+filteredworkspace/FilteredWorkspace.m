classdef FilteredWorkspace < internal.matlab.variableeditor.MLWorkspace & internal.matlab.variableeditor.MLNamedVariableObserver & dynamicprops




properties 
currentVariables = {  };
end 

methods 
function this = FilteredWorkspace(  )
this@internal.matlab.variableeditor.MLNamedVariableObserver( 'who', 'base' );
this.updateVariables( evalin( 'base', 'who' ) );
end 

function s = who( this )
s = this.currentVariables;
end 

function val = getPropValue( ~, propName )
val = evalin( 'base', propName );
end 

function clearOldProps( this )
for i = 1:length( this.currentVariables )
propName = this.currentVariables{ i };
if isprop( this, propName )
p = findprop( this, propName );
delete( p );
end 
end 
this.currentVariables = {  };
end 

function variableChanged( this, options )
R36
this
options.newData = [  ];
options.newSize = 0;
options.newClass = '';
options.eventType = internal.matlab.datatoolsservices.WorkspaceEventType.UNDEFINED;
end 
this.updateVariables( options.newData );
end 

function updateVariables( this, variables )
if ~iscell( variables )
return ;
end 


this.clearOldProps(  );


for i = 1:length( variables )
propName = variables{ i };
value = evalin( 'base', propName );


if this.isValidVariable( propName, value )
this.currentVariables{ end  + 1 } = propName;
if ~isprop( this, propName )
p = this.addprop( propName );
p.Dependent = true;
p.GetMethod = @( this )( this.getPropValue( propName ) );
end 
end 
end 
this.notify( 'VariablesChanged' );
end 

function isValid = isValidVariable( ~, ~, value )
isValid = true;
if ~istimetable( value )
isValid = ( isa( value, 'double' ) || isa( value, 'single' ) ) ...
 && allfinite( value ) && isvector( value ) ...
 && numel( value ) > 3;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGRvMMU.p.
% Please follow local copyright laws when handling this file.

