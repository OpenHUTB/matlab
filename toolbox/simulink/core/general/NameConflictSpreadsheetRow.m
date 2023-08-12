classdef NameConflictSpreadsheetRow < handle

properties 
m_controller;
m_id;
m_rowObj;
m_resolution;
m_valueStr;
m_sourceStr;
end 

methods 

function this = NameConflictSpreadsheetRow( controller, id, rowObj, action, valueStr, sourceStr )
this.m_controller = controller;
this.m_id = id;
this.m_rowObj = rowObj;
this.m_resolution = action;
this.m_valueStr = valueStr;
this.m_sourceStr = sourceStr;
end 

function bIsValid = isValidProperty( ~, ~ )
bIsValid = true;
end 

function bIsReadOnly = isReadonlyProperty( ~, prop )
bIsReadOnly = ~isequal( prop, DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Action' ) );
end 

function bIsEditable = isEditableProperty( ~, prop )
bIsEditable = isequal( prop, DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Action' ) );
end 

function value = getDisplayLabel( this )
value = this.m_rowObj.getPropValue( 'Name' );
end 
function value = getDisplayIcon( this )
value = this.m_rowObj.getDisplayIcon(  );
end 

function value = getPropValue( this, prop )
try 
if isequal( prop, DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Action' ) )
value = this.m_resolution;
elseif isequal( prop, DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Source' ) )
value = this.m_sourceStr;
elseif isequal( prop, DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Value' ) )
value = this.m_valueStr;
else 
value = this.m_rowObj.getPropValue( prop );
end 
catch 
value = '';
end 
end 

function type = getPropDataType( ~, prop )
if isequal( prop, DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Action' ) )
type = 'enum';
else 
type = 'string';
end 
end 

function values = getPropAllowedValues( ~, prop )
if isequal( prop, DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Action' ) )
values = { DAStudio.message( 'modelexplorer:DAS:PasteConflict_Skip' ),  ...
DAStudio.message( 'modelexplorer:DAS:PasteConflict_Replace' ),  ...
DAStudio.message( 'modelexplorer:DAS:PasteConflict_KeepBoth' ),  ...
 };
else 
values = '';
end 
end 

function setPropValue( this, prop, value )
if isequal( prop, DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Action' ) )
this.m_resolution = value;
this.m_controller.setAction( this.m_id, value );
end 
end 
end 

methods ( Access = private )

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOMjg9_.p.
% Please follow local copyright laws when handling this file.

