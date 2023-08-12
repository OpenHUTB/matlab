classdef ( Abstract )WritableMetadataNodeMixin < coderapp.internal.config.runtime.ReadableMetadataNodeMixin


methods 
function modified = setMetadata( this, prop, value )
R36
this
prop char{ mustBeNonempty( prop ) }
value = [  ]
end 
if isempty( this.MetadataMap )
error( 'MetadataMap not set' );
end 
entry = this.MetadataMap.getByKey( prop );
modified = false;
if nargin == 3
if isempty( entry )
entry = coderapp.internal.config.runtime.Metadata(  ...
struct( 'Property', prop, 'Value', [  ] ) );
this.MetadataMap.add( entry );
modified = true;
end 
if ~isequal( entry.Value, value )
entry.Value = value;
modified = true;
end 
elseif ~isempty( entry )
entry.destroy(  );
modified = true;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpOeKfY3.p.
% Please follow local copyright laws when handling this file.

