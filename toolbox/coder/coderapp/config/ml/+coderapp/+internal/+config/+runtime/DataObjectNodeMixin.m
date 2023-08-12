classdef ( Abstract )DataObjectNodeMixin < coderapp.internal.log.Loggable


properties ( Access = protected )
DataObject coderapp.internal.config.data.DataObject
DataObjectStrategy coderapp.internal.config.DataObjectStrategy
end 

methods 
function modified = setAttr( this, attr, attrValue, ~ )
modified = this.doSetAttr( attr, attrValue );
end 

function attrValue = getAttr( this, attr )
attrValue = this.DataObject.( this.validateAttrName( attr ) );
end 

function exported = exportAttr( this, attr )
exported = this.DataObjectStrategy.export( attr, this.DataObject.( attr ) );
end 

function modified = importAttr( this, attr, attrValue, ~ )
modified = this.setAttr( attr, this.DataObjectStrategy.import( attr, attrValue ) );
end 

function yes = isAttr( this, attr )
if isstring( attr ) && ~isscalar( attr )
attr = cellstr( attr );
end 
if iscell( attr )
yes = ismember( attr, lower( this.DataObjectStrategy.Attributes ) );
else 
yes = any( strcmpi( attr, this.DataObjectStrategy.Attributes ) );
end 
end 

function adjusted = validateAttrName( this, attr )
if any( strcmp( attr, this.DataObjectStrategy.Attributes ) )
adjusted = attr;
else 
proper = this.DataObjectStrategy.Attributes;
adjusted = proper{ strcmpi( attr, proper ) };
if isempty( adjusted )
error( 'Unregonized attribute "%s"', attr );
end 
end 
end 

function attrs = getAttributeNames( this )
if ~isempty( this.DataObjectStrategy )
attrs = this.DataObjectStrategy.Attributes;
else 
attrs = {  };
end 
end 
end 

methods ( Access = protected )
function modified = doSetAttr( this, attr, attrValue )
R36
this
attr char
attrValue
end 

if ~isequal( attrValue, this.DataObject.( attr ) )
this.Logger.debug( @(  )sprintf( 'Setting attribute "%s" to %s', attr,  ...
coderapp.internal.value.valueToExpression( attrValue ) ) );
this.DataObject.( attr ) = attrValue;
modified = true;
else 
modified = false;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpsH0F8W.p.
% Please follow local copyright laws when handling this file.

