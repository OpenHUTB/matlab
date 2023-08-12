classdef ( Sealed )ConfigurationEventData < event.EventData


properties ( SetAccess = immutable )
Changes struct
end 

properties ( Dependent, SetAccess = immutable )
Keys
end 

methods 
function this = ConfigurationEventData( changes )
R36
changes struct
end 
this.Changes = changes;
end 

function keys = get.Keys( this )
keys = { this.Changes.key };
end 

function changed = isChanged( this, key, attr )
R36
this( 1, 1 )
key{ mustBeTextScalar( key ) }
attr{ mustBeTextScalar( attr ) } = ''
end 
idx = find( strcmp( key, this.Keys ), 1 );
changed = ~isempty( idx );
if changed && ~isempty( attr )
changed = any( strcmp( attr, this.Changes( idx ).attributes ) );
end 
end 

function attrs = getChangedAttributes( this )
idx = find( strcmp( key, this.Keys ), 1 );
if ~isempty( idx )
attrs = this.Changes( idx ).attributes;
else 
attrs = {  };
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp4cBpoT.p.
% Please follow local copyright laws when handling this file.

